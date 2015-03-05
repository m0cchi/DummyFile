require 'stringio'

class File
  attr_reader :path
  @@vfile = {}
  
  def initialize(path, mode = 'r',perm = 0666)
    if @@vfile.include? path
      @io = @@vfile[path]
      @hash = @io.string.hash
    else
      @io = StringIO.new ''
      @hash = ''.hash
      @@vfile[path] = @io
    end
    @path = path
    @buf = []
    @old_hash = @hash - 1
    @mode = parse_mode(mode)
  end

  def parse_mode(mode)
    modes = []
    if /^r/ === mode
      modes << :r
    elsif /^w/ === mode
      modes << :w
    elsif /^b/ === mode
      modes << :b
    elsif /^t/ === mode
      modes << :t
    else
      modes << :r
    end
    modes += [:w,:r] if /\+/ === mode

    modes.uniq
  end
  
  def check_mode(mode)
    @mode.include?(mode) ? true : (raise IOError)
  end

  def <<(str)
    self.write(str)
  end
  
  def to_s
    @io.string
  end
  
  def write(str)
    self.check_mode(:w)
    c = @io.write(str)
    @hash = self.to_s.hash
    c
  end
  
  def each_line(rs = "",limit = 0)
    self.check_mode(:r)
    @io.string.split("\n").each do |x|
      yield x
    end
  end
  
  def getc
    self.check_mode(:r)
    unless @old_hash == @hash    
      @old_hash = @hash
      @buf = self.to_s.split('')
    end    
    @buf.shift
  end
  
  def gets
    buf = ''
    ch = ''
    while (ch = self.getc) != "\n" && ch 
      buf << ch
    end
    buf << ch.to_s
  end

  def ungetc(ch)
    @buf.unshift(ch)
  end

  def read(length = nil,outbuf = '')
    buf = ''
    if length
      (0..length).each do
        buf << self.getc
      end
      outbuf.sub!(/^.#{length}/,buf)
    else
      outbuf.gsub!(/./,'')
      outbuf << self.readlines.join('')
    end
    buf
  end

  def read_nonblock(maxlen, outbuf = '')
    read(maxlen,outbuf)
  end

  def readpartial(maxlen, outbuf = '')
    read(maxlen,outbuf)
  end

  def sysread(maxlen, outbuf = '')
    read(maxlen,outbuf)
  end

  def readchar
    ch = self.getc
    raise EOFError unless ch
  end

  def readline
    line = self.gets
    raise EOFError unless line
    line
  end

  def readlines(rs = '',limit = 0)
    lines = []
    self.each_line(rs,limit) do |l|
      lines << l
    end
    lines
  end

  def clear
    @io.close
    @io = StringIO.new ''
    @@vfile[path] = @io
    self
  end

  def close
    @buf = nil
    @hash = nil
    @old_hash = nil
    @path = nil
  end

  def self.foreach(path, rs = '',&block)
    self.open(path).each_line(block)
  end

  def self.open(path,mode = 'r', perm = 0666,&block)
    f = self.new(path,mode,perm)
    block.call f if block
    f
  end

end
