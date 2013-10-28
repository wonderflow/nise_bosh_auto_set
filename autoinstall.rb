require 'rubygems'
require 'net/ssh'
require 'net/scp'

class Install

  def initialize(job,index,host,user,password)
    @job = job
    @index = index
    @host = host
    @user = user
    @password = password

    @filename = @job+"_"+@index.to_s
  end

  def send_file(ssh,srcpath,despath)
    if File.exist?srcpath
      ssh.scp.upload!(srcpath,despath)
      return "#{srcpath} upload Done."
    else
      return "ERROR: Don't have such File: #{srcpath}"
    end
  end

  #send huge blobs with a proceed tar
  def send_blobs(ssh,srcpath,despath)
    if File.exist?srcpath
      #puts srcpath.split('/').inspect+"  srcfile"
      if ssh.exec("ls").inspect.include? srcpath.split('/')[-1]
        # TODO : this block no use
        return "Blob File aready exists!"
      end
      ssh.scp.upload!( srcpath , despath , :recursive => true )do|ch, name, sent, total|
        percent = (sent.to_f*100 / total.to_f).to_i
        if percent%5==0 
          print "\r#{@host}: #{name}: #{percent}%"
        end
      end
      print "\n"
      return "#{srcpath} upload Done."
    else
      return "ERROR: Don't have such File: #{srcpath}"
    end
  end

  def send_all(ssh)
    files = []
    files << File.join('config','sources.list')
    files << File.join('shell','autoinstall.sh')
    files << File.join('shell','env.sh')
    files << File.join('config','cfyml',@filename+"_cf.yml")
    files << File.join('config','cloudagentyml',@filename+"_cloud.yml")
    files << File.join('shell','jobs',@filename+".sh")
    blobs = []
    blobs << File.join('blobs','ruby-1.9.3-p448.tar.gz')
    blobs << File.join('blobs','rubygems-1.8.17.tgz')
    blobs << File.join('blobs','yaml-0.1.4.tar.gz')
    blobs << File.join('blobs','adeploy.gz')
    #send some files
    files.each do |f|
      puts send_file(ssh,f,'.')
    end
    #send the important blob files
    blobs.each do |f|
      puts send_blobs(ssh,f,'.')
    end
  end

  def exec(ssh,log,instructor)
    ssh.open_channel do |channel|
      channel.request_pty do |ch,success|
        raise "I can't get pty request " unless success
        puts "exec: "+instructor
        ch.exec(instructor)
        # TODO : add exception solving code
        # exception see pictures in Picture
        ch.on_data do |ch,data|
          data.inspect
          if data.inspect.include?"[sudo]" 
            channel.send_data("password\n")
          elsif data.inspect.include?"Enter your password"
            channel.send_data("password\n")
          elsif data.inspect.include?"[Y/n]"
            channel.send_data("y\n")
          elsif data.inspect.include?"[y/N]"
            channel.send_data("y\n")
          else
            log.puts data.strip
            #puts data.strip
          end
        end
      end
    end
  end

  #connect remote vm and run logical things
  def remote_connect(host,user,password)
    log_file = File.open(File.join("log",host+".log"),"w+")
    Net::SSH.start(host,user,:password=>password) do |ssh|
      puts host+" connected."
      send_all ssh
      exec ssh,log_file,"bash #{@filename+'.sh'}"
    end
    log_file.close
  end 

  def work()
    remote_connect(@host,@user,@password)
  end

end
