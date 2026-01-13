# frozen_string_literal: true

PaperTrail.config.has_paper_trail_defaults = { versions: { name: :versions, class_name: 'Version' } }
PaperTrail.config.serializer = PaperTrail::Serializers::JSON
