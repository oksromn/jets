require "thor"
require "jets/cli/help"

module Jets

  class CLI < Command
    class_option :verbose, type: :boolean
    class_option :noop, type: :boolean

    desc "build", "Builds and prepares project for Lambda"
    long_desc Help.build
    def build
      Jets::Build.new(options).run
    end

    desc "deploy", "Deploys project to Lambda"
    long_desc Help.deploy
    option :capabilities, type: :array, desc: "iam capabilities. Ex: CAPABILITY_IAM, CAPABILITY_NAMED_IAM"
    option :iam, type: :boolean, desc: "Shortcut for common IAM capabilities: CAPABILITY_IAM, CAPABILITY_NAMED_IAM"
    def deploy
      Jets::Deploy.new(options).run
    end

    desc "delete", "Delete project and all its resources"
    long_desc Help.delete
    option :sure, type: :boolean, desc: "Skip are you sure prompt."
    def delete
      Jets::Delete.new(options).run
    end

    desc "new", "Creates new starter project"
    long_desc Help.new_long_desc
    option :template, default: "starter", desc: "Starter template to use."
    def new(project_name)
      Jets::New.new(project_name, options).run
    end

    desc "server", "Runs a local server for development"
    long_desc Help.server
    option :port, aliases: :p, default: "8888", desc: "use PORT"
    option :host, aliases: :h, default: "127.0.0.1", desc: "listen on HOST"
    def server
      # shell out to shotgun for automatic reloading
      o = options
      system("bundle exec shotgun --port #{o[:port]} --host #{o[:host]}")
    end

    desc "routes", "Print out your application routes"
    long_desc Help.routes
    def routes
      puts Jets::Router.routes_help
    end

    desc "console", "REPL console with Jets environment loaded"
    long_desc Help.console
    def console
      Jets::Console.run
    end

    desc "call FUNCTION EVENT", "Invoke or 'call' a lambda function on AWS"
    long_desc Help.call
    option :invocation_type, default: "RequestResponse", desc: "RequestResponse, Event, or DryRun"
    option :log_type, default: "Tail", desc: "Works if invocation_type set to RequestResponse"
    option :qualifier, desc: "Lambda function version or alias name"
    option :show_log, type: :boolean, desc: "Shows last 4KB of log in the x-amz-log-result header"
    option :lambda_proxy, type: :boolean, default: true, desc: "Enables automatic Lambda proxy transformation of the event payload"
    def call(function_name, payload='')
      Jets::Call.new(function_name, payload, options).run
    end
    # Command is called 'call' because invoke is a Thor keyword.

    desc "db COMMAND1 COMMAND2 ...", "DB tasks. Delegates to rake db:command1:command2"
    long_desc Help.db
    def db(*args)
      Jets::Db.new(options).run_command(*args)
    end

    desc "process TYPE", "process subtasks"
    subcommand "process", Jets::Process

    desc "dynamodb TYPE", "dynamodb subtasks"
    subcommand "dynamodb", Jets::Dynamodb
  end
end
