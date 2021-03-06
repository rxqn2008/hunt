﻿/*
 * Hunt - Hunt is a high-level D Programming Language Web framework that encourages rapid development and clean, pragmatic design. It lets you build high-performance Web applications quickly and easily.
 *
 * Copyright (C) 2015-2018  Shanghai Putao Technology Co., Ltd
 *
 * Website: www.huntframework.com
 *
 * Licensed under the Apache-2.0 License.
 *
 */

module hunt.http.nullbuffer;

import kiss.container.ByteBuffer;

final class NullBuffer : Buffer
{
    override @property bool eof() const {return true;}

    override size_t read(size_t size, scope void delegate(in ubyte[]) cback){ return 0;}
    override size_t write(in ubyte[] data) { return 0;}

    override void rest(size_t size = 0){}
    override @property size_t length() const{ return 0;}
    
    override size_t readLine(scope void delegate(in ubyte[]) cback){return 0;} //回调模式，数据不copy
    
    override size_t readAll(scope void delegate(in ubyte[]) cback){return 0;}
    
    override size_t readUtil(in ubyte[] data, scope void delegate(in ubyte[]) cback){return 0;}
    
    override size_t readPos(){return 0;}

    override size_t set(size_t pos,in ubyte[] data){return 0;}
}

@property defaultBuffer(){return _default;}

shared static this(){
    _default =  new NullBuffer;
}

private:
__gshared NullBuffer _default;