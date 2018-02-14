module Email


  ChangeStartNotification = {
    :subject => 'STARTING: <%= @data.number %> <%= @data.short_description %>',
    :to => ENV['CHANGE_NOTIFICATION_RECIPIENTS'],
    :from => ENV['CHANGE_NOTIFICATION_FROM'],
    :template => 'change_start_notification'
  }
  ChangeEndNotification = {
    :subject => 'COMPLETE: <%= @data.number %> <%= @data.short_description %>',
    :to => ENV['CHANGE_NOTIFICATION_RECIPIENTS'],
    :from => ENV['CHANGE_NOTIFICATION_FROM'],
    :template => 'change_end_notification'
  }

  class EmailTemplate
    def initialize(template_name)
      @template_contents = File.read("email_templates/#{template_name}.erb")
    end

    def prepare(data)
      erb_template = ERB.new(@template_contents)
      @data = data
      erb_template.result(binding)
    end
  end

  class Message
    def initialize(type, data)
      @data = data
      @type = type
    end

    def message
      email = {message: {
        subject: subject,
        from: {
          emailAddress: {
            address: @type[:from]
          }},
        body: {
          contentType: 'HTML',
          content: content
        },
        toRecipients: [
          {
            emailAddress: {
              address: @type[:to]
            }
          }
        ]
      }
      }
      return email
    end

    def subject
      sub_temp = ERB.new(@type[:subject])
      subject = sub_temp.result(binding)
      return subject
    end

    def content
      template = EmailTemplate.new(@type[:template])
      content = template.prepare(@data)
      return content
    end

    def self.email_type_mapper(action)
      case action
        when :change_start
          return Email::ChangeStartNotification
        when :change_end
          return Email::ChangeEndNotification
      end
    end

  end

end
