require 'active_support/core_ext'
require 'fileutils'
require 'listen'

# Utilities for importing/exporting data to/from the repl
module ImEx
  mattr_reader :editor, :editor_wait, :dir, :watches

  @@editor = 'atom'
  @@editor_wait = 'atom -w'
  @@dir = File.expand_path('~/repl_files')
  @@watches ||= {}
  FileUtils.mkdir(self.dir) unless File.exist?(self.dir)
  @@listener ||= nil

  def self.listen_to(path, block)
    unless @@listener
      @@listener = Listen.to(self.dir) do |modified, added, removed|
        modified.each do |path|
          self.watches[path].call(path) if self.watches[path]
        end
      end
      @@listener.start
      at_exit {@@listener.stop}
    end
    self.watches[path] = block
  end

  # Open editor and return filename. If a block is provided, call
  # it with the file path every time the file changes.
  def self.edit(text = nil, ext = nil, wait = false, &block)
    path = "#{self.dir}/#{Time.now.iso8601.gsub(/[-:]/, '')}#{ext}"
    File.write(path, text.to_s)
    self.listen_to(path, block) if block
    system "#{wait ? self.editor_wait : self.editor} #{path}"
    path
  end

  # Open editor, wait for it to be closed, and return the content of the file.
  def self.input(text = nil, ext = nil)
    path = self.edit(text, ext, true)
    File.read(path)
  end
end
