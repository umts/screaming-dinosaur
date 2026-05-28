# frozen_string_literal: true

class Feed
  attr_reader :roster

  delegate :to_ical, to: :calendar

  def initialize(roster)
    @roster = roster
    @assignments = roster.assignments.with_start_datetimes.preload(:user).where.associated(:user).order(:end_datetime)
  end

  private

  def calendar
    Icalendar::Calendar.new.tap do |cal|
      cal.prodid = '-//umasstransit.org//umts-oncall.admin.umass.edu//EN'
      cal.publish
      @assignments.each { |assignment| cal.add_event event(assignment) }
    end
  end

  def event(assignment) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    Icalendar::Event.new.tap do |e|
      e.uid = "#{assignment.id}@screaming-dinosaur"
      e.dtstamp = event_datetime(Time.current)
      e.dtstart = event_datetime(assignment.start_datetime)
      e.dtend = event_datetime(assignment.end_datetime)
      e.summary = assignment.user.full_name
      e.description = "#{assignment.user.full_name} is on call for #{assignment.roster.name}."
      e.status = 'CONFIRMED'
      e.created = event_datetime(assignment.created_at)
      e.last_modified = event_datetime(assignment.updated_at)
    end
  end

  def event_datetime(time) = Icalendar::Values::DateTime.new(time.utc, tzid: 'UTC')
end
