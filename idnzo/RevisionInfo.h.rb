#!/usr/bin/env ruby

# RevisionInfo.h.rb
# DNZO
#
# Created by Taylor Hughes on 12/8/09.
# Copyright 2009 Two-Stitch Software. All rights reserved.

# Creates $DSTROOT/RevisionInfo.h, which is included in the build and defines SVN_REVISION

require 'fileutils'

def main
  revs = `svn info #{ENV['SRCROOT'].inspect} -R |grep Revision`
  revision = revs.collect do |line|
    line.gsub(/[^\d]+/,'').to_i
  end.max
  FileUtils.mkdir_p(ENV['DERIVED_FILES_DIR'])
  File.open(File.join(ENV['DERIVED_FILES_DIR'], 'RevisionInfo.h'), 'w') do |file|
    file.puts '#define SVN_REVISION @"%d"' % revision
  end
end

main if $0 == __FILE__