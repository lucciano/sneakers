require 'spec_helper'

describe 'base::default' do
  let(:chef_run) {
    chef_run = ChefSpec::ChefRunner.new(platform:'debian', version:'6.0.5')
    chef_run.converge 'base::default'
  }

  it 'creates /etc/apt/sources.list' do
    chef_run.should create_file_with_content '/etc/apt/sources.list', '# Managed by chef'
  end

%w[lsb lsb-release tzdata ncurses-term lsof strace snmpd locales vim bsd-mailx mingetty
  sudo build-essential xfsprogs ssh less psmisc rsync pwgen ntpdate ntp sysstat iotop git
  screen telnet debian-keyring aspell atop ffmpeg ghostscript imagemagick mysql-client ncftp
  slay swish-e bind9-host bc wget curl lynx git-core subversion mercurial bzr].each do |pkg|
    it "installs #{pkg}" do
      chef_run.should install_package pkg
    end
  end

  it 'creates /etc/skel/.gemrc' do
    chef_run.should create_cookbook_file '/etc/skel/.gemrc'
  end

  it 'creates timezone file' do
    file = chef_run.file chef_run.node[:timezone][:tz_file]
    file.mode.should eq '00644'
    file.should be_owned_by 'root', 'root'
    file.content.should eq chef_run.node[:timezone][:zone]
    file.should notify 'execute[update-tzdata]', :run
  end

  it 'creates /etc/mime.types' do
    chef_run.should create_cookbook_file '/etc/mime.types'
    file = chef_run.cookbook_file '/etc/mime.types'
    file.mode.should eq 00644
    file.should be_owned_by 'root', 'root'
  end

  it "installs postfix" do
    chef_run.should install_package 'postfix'
  end

  it 'creates /etc/postfix/main.cf' do
    chef_run.should create_cookbook_file '/etc/postfix/main.cf'
  end

  it 'sets postfix service' do
    pending 'sets postfix service'
  end
end
