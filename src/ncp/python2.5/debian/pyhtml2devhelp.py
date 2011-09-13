#! /usr/bin/python

import formatter, htmllib
import os, sys, re

class PyHTMLParser(htmllib.HTMLParser):
    pages_to_include = set(('modindex.html',
                           'api/api.html', 'doc/doc.html', 'ext/ext.html',
                           'lib/lib.html', 'mac/mac.html', 'ref/ref.html',
                           'tut/tut.html', 'inst/inst.html', 'dist/dist.html',
                            'whatsnew/whatsnew25.html'))
    include_modindex = False

    def __init__(self, formatter, basedir, fn, indent, parents=set()):
        htmllib.HTMLParser.__init__(self, formatter)
        self.basedir = basedir
        self.dir, self.fn = os.path.split(fn)
        self.data = ''
        self.parents = parents
        self.link = {}
        self.indent = indent
        self.last_indent = indent - 1
        self.sub_indent = 0

    def process_link(self):
        new_href = os.path.join(self.dir, self.link['href'])
        text = self.link['text']
        indent = self.indent + self.sub_indent
        while self.last_indent >= indent:
            print '%s</sub>' % ('  ' * self.last_indent)
            self.last_indent -= 1
        print '%s<sub link="%s" name="%s">' % ('  ' * indent, new_href, text)
        self.last_indent = self.indent + self.sub_indent

    def start_ul(self, attrs):
        self.sub_indent += 1

    def end_ul(self):
        self.sub_indent -= 1

    def start_dl(self, attrs):
        self.sub_indent += 1

    def end_dl(self):
        self.sub_indent -= 1

    def start_a(self, attrs):
        self.link = {}
        for attr in attrs:
            self.link[attr[0]] = attr[1]
        self.data = ''
        
    def end_a(self):
        text = self.data.replace('\t', '').replace('\n', ' ').replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
        self.link['text'] = text
        # handle a tag without href attribute
        try:
            href = self.link['href']
        except KeyError:
            return

        abs_href = os.path.join(self.basedir, href)
        if abs_href in self.parents:
            return
        if href.startswith('..') or href.startswith('http:') \
               or href.startswith('mailto:') or href.startswith('news:'):
            return
        if self.link.get('rel', None) in ('prev', 'parent', 'next', 'contents', 'index'):
            return
        if href == 'about.html':
            return
        if href == 'modindex.html' and not self.include_modindex:
            return
        self.process_link()
        if href in self.pages_to_include:
            self.parse_file(os.path.join(self.dir, href))
        if href == 'tut/tut.html':
            self.include_modindex = True

    def finish(self):
        indent = self.indent + self.sub_indent
        while self.last_indent > indent:
            print '%s</sub>' % ('  ' * self.last_indent)
            self.last_indent -= 1

    def handle_data(self, data):
        self.data += data

    def parse_file(self, href):
        # TODO basedir bestimmen
        parent = os.path.join(self.basedir, self.fn)
        self.parents.add(parent)
        parser = PyHTMLParser(formatter.NullFormatter(),
                              self.basedir, href, self.indent + 1,
                              self.parents)
        text = file(self.basedir + '/' + href).read()
        parser.feed(text)
        parser.finish()
        parser.close()
        if parent in self.parents:
            self.parents.remove(parent)

class PyIdxHTMLParser(htmllib.HTMLParser):
    def __init__(self, formatter, basedir, fn, indent):
        htmllib.HTMLParser.__init__(self, formatter)
        self.basedir = basedir
        self.dir, self.fn = os.path.split(fn)
        self.data = ''
        self.link = {}
        self.indent = indent
        self.active = False
        self.header = ''
        self.last_letter = 'letter-z'

    def process_link(self):
        new_href = os.path.join(self.dir, self.link['href'])
        text = self.link['text']
        if not self.active:
            return
        if text == '[Link]':
            return
        if self.link.get('rel', None) in ('prev', 'parent', 'next', 'contents', 'index'):
            return
        indent = self.indent
        print '%s<function link="%s" name="%s"/>' % ('  ' * indent, new_href, text)

    def start_h2(self, attrs):
        for k, v in attrs:
            if k == 'id':
                self.header = v
                if v == 'letter-_':
                    self.active = True

    def start_table(self, attrs):
        pass

    def end_table(self):
        if self.header == self.last_letter:
            self.active = False

    def start_a(self, attrs):
        self.link = {}
        for attr in attrs:
            self.link[attr[0]] = attr[1]
        self.data = ''
        
    def end_a(self):
        text = self.data.replace('\t', '').replace('\n', ' ').replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
        self.link['text'] = text
        # handle a tag without href attribute
        try:
            href = self.link['href']
        except KeyError:
            return
        self.process_link()

    def handle_data(self, data):
        self.data += data

def main():
    base = sys.argv[1]
    fn = sys.argv[2]

    parser = PyHTMLParser(formatter.NullFormatter(), base, fn, indent=0)
    print '<?xml version="1.0" encoding="iso-8859-1"?>'
    print '<book title="Python %s Documentation" name="Python" version="%s" link="index.html">' % (sys.version[:3], sys.version[:3])
    print '<chapters>'
    parser.parse_file(fn)
    print '</chapters>'

    print '<functions>'

    fn = 'lib/genindex.html'
    parser = PyIdxHTMLParser(formatter.NullFormatter(), base, fn, indent=1)
    text = file(base + '/' + fn).read()
    parser.feed(text)
    parser.close()

    fn = 'api/genindex.html'
    parser = PyIdxHTMLParser(formatter.NullFormatter(), base, fn, indent=1)
    text = file(base + '/' + fn).read()
    parser.last_letter = 'letter-v'
    parser.feed(text)
    parser.close()

    print '</functions>'
    print '</book>'

main()
