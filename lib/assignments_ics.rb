# frozen_string_literal: true

class AssignmentsIcs
  def initialize(assignments)
    @assignments = assignments
  end

  def output
    calendar.to_ical
  end

  private

  def calendar
    Icalendar::Calendar.new.tap do |cal|
      cal.prodid = '-//umasstransit.org//umts-oncall.admin.umass.edu//EN'
      cal.publish

      @assignments.each { |assignment| cal.add_event event(assignment) }
    end
  end

  # It looks bad to Rubocop because every line is at least two method calls.
  # But, it's really just a builder pattern.
  # rubocop:disable Metrics/AbcSize
  def event(assignment)
    Icalendar::Event.new.tap do |e|
      e.uid = "#{assignment.id}@screaming-dinosaur"
      e.status = 'CONFIRMED'
      e.dtstamp = assignment.created_at.to_fs(:ical)
      e.last_modified = assignment.updated_at.to_fs(:ical)
      e.dtstart = Icalendar::Values::Date.new(assignment.start_date)
      e.dtend = Icalendar::Values::Date.new(1.day.after(assignment.end_date))
      e.summary = assignment.user.last_name
      e.description = <<-DESC.squish
        #{assignment.user.first_name} #{assignment.user.last_name} is on call
        for #{assignment.roster.name}.
      DESC
    end
  end
  # rubocop:enable Metrics/AbcSize
end
