require 'spec_helper'

describe SidetiqWorker do

  subject! do
    create :repository, source_address: 'remote.git', source_type: 'git',
      remote_type: 'mirror'
  end
  before{ Worker.clear }

  shared_examples 'perform' do |state, minutes, created_jobs_count|
    describe "state #{state}, imported " << (minutes ? "#{minutes} minutes ago" : "never before") do
      before do
        subject.update_attributes!(
          {state: state.to_s, imported_at: (minutes ? minutes.minutes.ago : nil)},
          {without_protection: true}
        )
        SidetiqWorker.new.perform
      end
      it("should create #{created_jobs_count} jobs"){ assert_equal Worker.jobs.count, created_jobs_count }
    end
  end

  include_examples 'perform', :processing, nil, 0
  include_examples 'perform', :processing,  20, 0
  include_examples 'perform', :done,       nil, 1
  include_examples 'perform', :done,        10, 0
  include_examples 'perform', :done,        20, 1
  include_examples 'perform', :failed,     nil, 0
  include_examples 'perform', :failed,      20, 0

end
