#!/usr/bin/python3

import inspect
import os
from pathlib import Path
import sys


def replace_line(file,replace_lines):
    rf=os.path.realpath(file)
    print("open",rf)
    ls=Path(rf).read_text().splitlines()
    for (ln,txt) in replace_lines:
        print(rf,ln,ls[ln],txt,ls[ln]==txt)
        ls[ln]=txt
    Path(file).write_text('\n'.join(ls)+"\n")
    pass

def cli_replace_line(f:str,seq):
    replace_list=[x.split(seq) for x in Path(f).read_text().splitlines()]
    replace_map={}
    for (f,line,txt) in replace_list:
        if f not in replace_map:
            replace_map[f]=[]
        replace_map[f].append((int(line)-1,txt))
    for f,replace_lines in replace_map.items():
        print("xxx",f)
        replace_line(f,replace_lines)

def main(argv):
    print(argv)
    fs={name:obj for name,obj in inspect.getmembers(sys.modules[__name__]) if (inspect.isfunction(obj))}
    key=f"cli_{argv[1]}".replace("-","_")
    if key not in fs:
        return
    f=fs[key]
    f(*argv[2:])
    # for name,f in fs.items():
    #     print(name)
    # replace_line("a.txt",[(1,"hello"),(2,"world")])

if __name__ == '__main__':
    main(sys.argv)