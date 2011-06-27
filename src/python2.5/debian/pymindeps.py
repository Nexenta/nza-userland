#! /usr/bin/python

# Matthias Klose
# Modified to only exclude module imports from a given module.

# Copyright 2004 Toby Dickenson
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject
# to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import sys, pprint
import modulefinder
import imp

class mymf(modulefinder.ModuleFinder):
    def __init__(self,*args,**kwargs):
        self._depgraph = {}
        self._types = {}
        self._last_caller = None
        modulefinder.ModuleFinder.__init__(self,*args,**kwargs)
        
    def import_hook(self, name, caller=None, fromlist=None):
        old_last_caller = self._last_caller
        try:
            self._last_caller = caller
            return modulefinder.ModuleFinder.import_hook(self,name,caller,fromlist)
        finally:
            self._last_caller = old_last_caller
            
    def import_module(self,partnam,fqname,parent):
        r = modulefinder.ModuleFinder.import_module(self,partnam,fqname,parent)
        if r is not None:
            caller = self._last_caller.__name__
            if '.' in caller:
                caller = caller[:caller.index('.')]
            callee =  r.__name__
            if '.' in callee:
                callee = callee[:callee.index('.')]
            #print "XXX last_caller", caller, "MOD", callee
            #self._depgraph.setdefault(self._last_caller.__name__,{})[r.__name__] = 1
            #if caller in ('pdb', 'doctest') or callee in ('pdb', 'doctest'):
            #    print caller, "-->", callee
            if caller != callee:
                self._depgraph.setdefault(caller,{})[callee] = 1
        return r
    
    def find_module(self, name, path, parent=None):
        if parent is not None:
            # assert path is not None
            fullname = parent.__name__+'.'+name
        else:
            fullname = name
        caller = self._last_caller.__name__
        if name in excluded_imports.get(caller, []):
            #self.msgout(3, "find_module -> Excluded", fullname)
            raise ImportError, name

        if fullname in self.excludes:
            #self.msgout(3, "find_module -> Excluded", fullname)
            raise ImportError, name

        if path is None:
            if name in sys.builtin_module_names:
                return (None, None, ("", "", imp.C_BUILTIN))

            path = self.path
        return imp.find_module(name, path)

    def load_module(self, fqname, fp, pathname, (suffix, mode, type)):
        r = modulefinder.ModuleFinder.load_module(self, fqname, fp, pathname, (suffix, mode, type))
        if r is not None:
            self._types[r.__name__] = type
        return r
        
def reduce_depgraph(dg):
    pass

# guarded imports, which don't need to be included in python-minimal
excluded_imports = {
    'hashlib': set(('_hashlib',)),
    'os': set(('nt', 'ntpath', 'os2', 'os2emxpath', 'mac', 'macpath',
               'riscos', 'riscospath', 'riscosenviron')),
    'optparse': set(('gettext',)),
    'pickle': set(('doctest',)),
    'platform': set(('tempfile',)),
    'socket': set(('_ssl',)),
    'subprocess': set(('threading',)),
    }

def main(argv):
    path = sys.path[:]
    debug = 0
    #exclude = ['__builtin__', 'sys', 'os']
    exclude = []
    mf = mymf(path,debug,exclude)
    for arg in argv:
        mf.run_script(arg)

    depgraph = reduce_depgraph(mf._depgraph)
    
    pprint.pprint({'depgraph':mf._depgraph,'types':mf._types})
    
if __name__=='__main__':
    main(sys.argv[1:])
