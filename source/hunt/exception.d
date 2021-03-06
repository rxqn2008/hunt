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

module hunt.exception;

import std.exception;
import collie.utils.exception;

mixin ExceptionBuild!("Hunt","");

class NotImplementedException : Exception
{
    this(string method)
    {
        super(method ~ " is not implemented");
    }
}
