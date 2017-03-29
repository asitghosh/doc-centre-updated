require 'spec_helper'

describe Roadmap do

  subject { build_stubbed(:roadmap) }

  it { should respond_to(:content) }
  it { should respond_to(:title) }
  it { should respond_to(:slug) }
  it { should respond_to(:permalink) }
  it { should respond_to(:redirect_to_first_child) }
  it { should respond_to(:sortable_order) }
  it { should respond_to(:pub_status) }

end
