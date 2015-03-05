require 'stringio'

class File
  @@vfile = {}

  def initialize(path, mode = 'r')
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
  
  def <<(str)
    self.write(str)
  end
  
  def to_s
    @io.string
  end
  
  def write(str)
    c = @mode.include?(:w) ? @io.write(str) : 0
    @hash = self.to_s.hash
    unless str.length === c
      raise IOError
    end
    c
  end
  
  def each_line(rs = "",limit = 0)
    @io.string.split("\n").each do |x|
      yield x
    end
  end
  
  def getc
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

  def self.open(path,&block)
    f = self.new(path)
    block.call f if block
    f
  end

end
