##############################################################################
# test_web_sympa.rb
#
# This is a test suite for the wwsympa.fcgi web interface. You should run 
# theese tests like so: ruby test_web_sympa.rb
#
# In order for these tests to run successfully you must use the dbi-dbrc
# library, and create an entry for 'test_wwsympa'. The user name should include
# the full domain, and the driver should be set to the URL:
#
# test_wwsympa postmaster@foo.org xxx http://foo.bar.org/sympa
#
# For all tests to complete successfully, you must use listmaster credentials.
##############################################################################


require 'dbi/dbrc'
require 'minitest/spec'
require 'minitest/autorun'
require 'mechanize'

describe "wwsympa" do
	@@list = 'testlist-' + (0..8).map{ rand(10) }.join

	def self.test_order
		:alpha
	end

	before do
		# Get the settings from the db
		info = DBI::DBRC.new('test_wwsympa')
		@url  = info.driver
    @user  = info.user
    @pass  = info.passwd

		# Setup a logged in mech instance to the site
		@browser = Mechanize.new
		@browser.redirect_ok = false
		page = @browser.get @url
		form = page.forms.first
		form.email = @user
		form.passwd = @pass
		page = form.submit

		# if we don't get a 302 then we failed
		if page.code != "302"
			print "username/password combination is invalid"
			exit
		end
		@browser.redirect_ok = true
	end

	after do
		# Log out the mech instance
		@browser.post(@url, {
			'action' => "logout", 
			'action_logout' => "Logout",
			'previous_action' => "",
		})
	end

	describe "listmaster is logged in" do

		it "can create a list" do
			page = @browser.post(@url, {
				:listname => @@list,
				:template => "confidential",
				:subject => @@list,
				:topics => "arts",
				:info => @@list,
				:action_create_list => "Submit+your+creation+request",
			})
			page.content.must_match /Your list is created/
		end

		it "can add a user to a list" do
			page = @browser.post(@url, {
				:list => @@list,
				:action => "add",
				:email => @user,
				:action_add => "Add",
			})
			page.save "test.html"
			page.content.must_match /1 subscribers added/
		end

		it "can add many users to a list" do
			page = @browser.post(@url, {
				:list => @@list,
				:used => "true",
				:dump => "test1@meow.com\ntest2@meow.com\ntest3@meow.com",
				:action_add => "Add",
			})
			page.content.must_match /3 subscribers added/
		end

		it "can delete a user from a list" do
			page = @browser.post(@url, {
				:list => @@list,
				:action_del => "Delete+selected+email+addresses",
				:email => @user
			})
			page.content.must_match /1 addresses have been removed/
		end

		it "can delete a list" do
			page = @browser.post(@url, {
				:list => @@list,
				:action_close_list => "Remove+List",
			})
			page.content.must_match /List has been closed/
		end

	end
end
