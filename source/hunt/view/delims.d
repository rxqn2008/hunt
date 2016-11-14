/*
 * Hunt - a framework for web and console application based on Collie using Dlang development
 *
 * Copyright (C) 2015-2016  Shanghai Putao Technology Co., Ltd 
 *
 * Developer: putao's Dlang team
 *
 * Licensed under the BSD License.
 *
 * template parsing is based on dymk/temple source from https://github.com/dymk/temple
 */
module hunt.view.delims;

import
std.traits,
	std.typecons;

/// Represents a delimer and the index that it is located at
template DelimPos(D = Delim)
{
	alias DelimPos = Tuple!(size_t, "pos", D, "delim");
}

/// All of the delimer types parsed by Temple
enum Delim
{
	Open,
	OpenStr,
	CloseShort,
	Close,
	CloseStr,
}

enum Delims = [EnumMembers!Delim];

/// Subset of Delims, only including opening delimers
enum OpenDelim  : Delim
{
	Open            = Delim.Open,
	OpenStr         = Delim.OpenStr
}
enum OpenDelims = [EnumMembers!OpenDelim];

/// Subset of Delims, only including close delimers
enum CloseDelim : Delim
{
	CloseShort = Delim.CloseShort,
	Close      = Delim.Close,
	CloseStr = Delim.CloseStr,
}
enum CloseDelims = [EnumMembers!CloseDelim];

/// Maps an open delimer to its matching closing delimer
/// Formally, an onto function
enum OpenToClose =
[
	OpenDelim.Open         : CloseDelim.Close,
	OpenDelim.OpenStr      : CloseDelim.CloseStr
];

string toString(in Delim d)
{
	final switch(d) with(Delim)
	{
		case Open:          return "{%";
		case OpenStr:       return "{{";
		case CloseShort:    return "\n";
		case Close:         return "%}";
		case CloseStr:         return "}}";
	}
}
/// Is the delimer a shorthand delimer?
/// e.g., `%=`, or `%`
bool isShort(in Delim d)
{
	return false;
}

/// Is the contents of the delimer evaluated and appended to
/// the template buffer? E.g. the content within `<%= %>` delims
bool isStr(in Delim d)
{
	switch(d) with(Delim)
	{
		case OpenStr     : return true;
		default: return false;
	}
}
