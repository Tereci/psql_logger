require "psql_logger/version"
require 'pg'

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
    end
    
    def log_start()
      @run_id = @connection.exec("select log.log('#{@pid}',null,'#{@task}','ETL','RUNNING','#{@task} RUNNING','',null);").values[0][0]
    end
    
    def log_end(status='OK', message='')
      fail "Run id is empty - you have to call log_start_task first." if @run_id.nil?
      @connection.exec("select log.log_status(#{@run_id},'#{@task}','#{status}','#{@task} #{status} #{message}',0);")
      @connection.close
    end
    
    def log_step_start(step)
      fail "Run id is empty - you have to call log_start_task first." if @run_id.nil?
      @connection.exec("select log.log('#{@pid}',#{@run_id},'#{step}','ETL','RUNNING','#{step} RUNNING','',null);")
    end
    
    def log_step_end(step)
      fail "Run id is empty - you have to call log_start_task first." if @run_id.nil?
      @connection.exec("select log.log_status(#{@run_id},'#{step}','OK','#{step} OK',0);")
    end
    
    def log_error(step, message, continue_on_error=false)
      fail "Run id is empty - you have to call log_start_task first." if @run_id.nil?
      status = continue_on_error ? 'WARNING' : 'ERROR'
      @connection.exec("select log.log_status(#{@run_id},'#{step}','#{status}','#{step} #{status} #{message}',0);")
      log_end(status, message) unless continue_on_error
    end
    
  end
end
