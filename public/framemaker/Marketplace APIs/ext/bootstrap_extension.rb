# Ruby extension to support generating Bootstrap components in Asciidoctor
# Supported components:  tabs and collapsable accordions
require 'asciidoctor/extensions'
Asciidoctor::Extensions.register do
  block do
    named :bootstrap
    on_contexts :paragraph,:open
    name_attributes 'component'
    process do |parent, reader, attrs|
      create_block parent, attrs['component'], reader.lines, attrs
    end
  end
end
