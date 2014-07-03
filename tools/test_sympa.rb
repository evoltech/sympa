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
require 'mini-smtp-server'
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

		# This is for issue #1187: https://labs.riseup.net/code/issues/1187
		it "can not add name on the user preferences page" do
			page = @browser.post(@url, {
				:gecos => "Mesuir Burf Letet",
				:lang => "en_US",
				:cookie_delay => "0",
				:action_setpref => "Submit",
			})

			page.content.match(/Mesuir Burf Letet/).must_be_nil
		end

		it "can add a user to a list" do
			page = @browser.post(@url, {
				:list => @@list,
				:action => "add",
				:email => @user,
				:action_add => "Add",
			})
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

		# This is for issue #6404: https://labs.riseup.net/code/issues/6404
		it "can not add a list with a name that ends in -admin" do
			listname = @@list +"-admin"
			page = @browser.post(@url, {
				:listname => listname,
				:template => "confidential",
				:subject => listname,
				:topics => "arts",
				:info => listname,
				:action_create_list => "Submit+your+creation+request",
			})

			if page.content.match(/Your list is created/)
				@browser.post(@url, {
					:list => listname,
					:action_close_list => "Remove+List",
				})
			end
				
			page.content.match(/Your list is created/).must_be_nil
		end

		# This is for issue #6404: https://labs.riseup.net/code/issues/6404
		it "can not add a list with a name that ends in -owner" do
			listname = @@list +"-owner"
			page = @browser.post(@url, {
				:listname => listname,
				:template => "confidential",
				:subject => listname,
				:topics => "arts",
				:info => listname,
				:action_create_list => "Submit+your+creation+request",
			})

			if page.content.match(/Your list is created/)
				@browser.post(@url, {
					:list => listname,
					:action_close_list => "Remove+List",
				})
			end
				
			page.content.match(/Your list is created/).must_be_nil
		end

		# This is for issue #6404: https://labs.riseup.net/code/issues/6404
		it "can not add a list with a name that ends in -request" do
			listname = @@list +"-request"
			page = @browser.post(@url, {
				:listname => listname,
				:template => "confidential",
				:subject => listname,
				:topics => "arts",
				:info => listname,
				:action_create_list => "Submit+your+creation+request",
			})

			if page.content.match(/Your list is created/)
				@browser.post(@url, {
					:list => listname,
					:action_close_list => "Remove+List",
				})
			end
				
			page.content.match(/Your list is created/).must_be_nil
		end


		# TODO: create a subsection here that stands up a smtp server as 
		# a dependency: https://github.com/aarongough/mini-smtp-server/blob/master/test/unit/mini_smtp_server_test.rb

		# Testing the email mechanisms:
		# Anything recieved with $robot in the To: header should get piped to
		# the sympa queue.  Everything else should get stored in a hash of arrays
		# indexed by message-id (?)
		# Can we make starting the smtp server a dependency (so that we do not
		# run these tests if postfix or something else is already a dependency)

		# To test DMARC all we have to do is subscribe users with known DMARC 
		# entries like gmail.com, yahoo.com, and aol.com.  The DNS lookup will be
		# done for thise servers and the DMARC munging should take place.

		def send_mail(message = $example_mail, from_address = "smtp@test.com", to_address = "some1@test.com")
      Net::SMTP.start('127.0.0.1', 2525) do |smtp|
        smtp.send_message(message, from_address, to_address)
        smtp.finish
        sleep 0.01
      end
    end

	end
end
