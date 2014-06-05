#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

require File.expand_path('../../spec_helper', __FILE__)

describe CopyProjectsController do
  let(:current_user) { FactoryGirl.create(:admin) }
  let(:redirect_path) { "source_project_settings" }
  let(:permission) { :copy_projects }
  let(:project) { FactoryGirl.create(:project, :is_public => false) }


  before do
    User.stub(:current).and_return current_user

    request.env['HTTP_REFERER'] = redirect_path
  end

  describe "copy_from_settings uses correct project to copy from" do
    before do
      get 'copy_project', :id => project.id, :coming_from => :settings
    end

    it { assigns(:project).should == project }
  end

  describe 'copy_from_settings permissions' do
    def fetch
      get 'copy_project', :id => project.id, :coming_from => :settings
    end

    it_should_behave_like "a controller action which needs project permissions"
  end

  shared_examples_for 'successful copy' do
    it { expect(flash[:notice]).to eq(I18n.t('copy_project.started', source_project_name: source_project.name, target_project_name: target_project_name)) }
  end

  describe 'copy creates a new project' do
    before do
      post 'copy',
           :id => project.id,
           :project => project.attributes.reject { |k,v| v.nil? }.merge({ :identifier => "copy", :name => "copy" })
    end

    def expect_redirect_to
      true
    end

    it_behaves_like 'successful copy' do
      let(:source_project) { project }
      let(:target_project_name) { "copy" }
    end

    it { expect(response).to redirect_to(redirect_path) }
  end

  describe 'copy permissions' do
    def fetch
      post 'copy',
           :id => project.id,
           :project => project.attributes.reject { |k,v| v.nil? }.merge({ :identifier => "copy", :name => "copy" })
    end

    def expect_redirect_to
      true
    end

    let(:permission) { [:copy_projects, :add_project] }
    let(:project) { FactoryGirl.create(:project, :is_public => false) }

    it_should_behave_like "a controller action which needs project permissions"
  end
end
