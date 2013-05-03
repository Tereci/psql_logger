require "psql_logger/version"
require 'pg'
require 'socket'

# Use for logging into postgresql database. log_start method should be always called first and log_end last unless run finishes with error - then call log_error with continue_on_error set to false as a last called method. run_id gets initialized in initialize method only in some edge cases - usually when previous run of logger for given pid wasn't used correctly and main task is still in state RUNNING. If the task is not RUNNING (which is how it should correctly be) run_id is initialized as late as in call of log_start. log_end and log_error with parameter continue_on_error set to false close connection to database.
module GDC
  class PsqlLogger
    
    attr_accessor :connection, :run_id, :pid, :run_class
    
    def initialize(host, dbname, user, password, pid, options = {})
      @pid = pid
      @run_class = options[:run_class] || "ETL"
      @task = options[:task] || "ETL run"
      @connection_hash = {
        :host => host,
        :dbname => dbname,
        :user => user,
        :password => password
      }
      @connection = PG::Connection.new(@connection_hash)
      @run_id = @connection.exec("select log.run_id('#{@pid}')").values[0][0]
      @local_hostname = options[:local_hostname] || Socket.gethostname
    end
    
    def log_start()
      @run_id = @connection.exec("select log.log('#{@pid}',null,'#{@task}','ETL','RUNNING','#{@task} RUNNING','',null,'#{@local_hostname}');").values[0][0]
      result = log_execution(@pid,'STARTED',"#{@task} RUNNING")
    end
    
    def log_end(status='OK', message='')
      fail "Run id is empty - you have to call log_start_task first." if @run_id.nil?
      @connection.exec("select log.log_status(#{@run_id},'#{@task}','#{status}','#{@task} #{status} #{message}',0,'#{@local_hostname}');")
      result = log_execution(@pid,'FINISHED',"#{@task} #{status} #{message}")
      @connection.close
    end
    
    def log_step_start(step)
      fail "Run id is empty - you have to call log_start_task first." if @run_id.nil?
      @connection.exec("select log.log('#{@pid}',#{@run_id},'#{step}','ETL','RUNNING','#{step} RUNNING','',null,'#{@local_hostname}');")
    end
    
    def log_step_end(step)
      fail "Run id is empty - you have to call log_start_task first." if @run_id.nil?
      @connection.exec("select log.log_status(#{@run_id},'#{step}','OK','#{step} OK',0,'#{@local_hostname}');")
    end
    
    def log_error(step, message, continue_on_error=false)
      fail "Run id is empty - you have to call log_start_task first." if @run_id.nil?
      status = continue_on_error ? 'WARNING' : 'ERROR'
      @connection.exec("select log.log_status(#{@run_id},'#{step}','#{status}','#{step} #{status} #{message}',0,'#{@local_hostname}');")
      result = log_execution(@pid,'ERROR',"#{step} #{status} #{message}")
      log_end(status, message) unless continue_on_error
    end
    
    def log_execution(pid,status,detailed_status)
      @connection.exec("select log2.log_execution('#{pid}','app','','#{status}','#{detailed_status}',NULL);")
    end
    
    
    
    
    
    
end
