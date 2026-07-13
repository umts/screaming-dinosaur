# frozen_string_literal: true

class StitchAmPmRosters < ActiveRecord::Migration[8.1]
  def up
    am = Roster.find_by(name: 'Transit Ops AM')
    eve = Roster.find_by(name: 'Transit Ops EVE')
    return if am.nil? || eve.nil?

    ops = Roster.create!(
      name: 'Transit Operations',
      phone: am.phone,
      created_at: [am.created_at, eve.created_at].min
    )

    move_memberships(from: [am, eve], to: ops)
    move_assignments(from: [am, eve], to: ops)

    am.delete
    eve.delete
  end

  def down
    ops = Roster.find_by(name: 'Transit Operations')
    return if ops.nil?

    am = Roster.create!(name: 'Transit Ops AM', phone: ops.phone, created_at: ops.created_at)
    eve = Roster.create!(name: 'Transit Ops EVE', phone: ops.phone, created_at: ops.created_at)

    ops.memberships.each do |membership|
      Membership.create!(roster: am, user: membership.user, admin: membership.admin)
      Membership.create!(roster: eve, user: membership.user, admin: membership.admin)
    end
    Assignment.where(roster: ops).delete_all
    Membership.where(roster: ops).delete_all
    ops.delete
  end

  private

  def move_memberships(from:, to:)
    from.each do |roster|
      roster.memberships.to_a.each do |membership|
        existing = Membership.find_by(roster: to, user: membership.user)
        if existing
          existing.update!(admin: existing.admin || membership.admin)
          membership.destroy!
        else
          membership.update!(roster: to)
        end
      end
    end
  end

  def move_assignments(from:, to:)
    from.each do |roster|
      roster.assignments.to_a.each do |assignment|
        end_datetime = assignment.end_datetime
        end_datetime += 1.second while Assignment.exists?(roster: to, end_datetime: end_datetime)
        assignment.update!(roster: to, end_datetime: end_datetime)
      end
    end
  end
end
