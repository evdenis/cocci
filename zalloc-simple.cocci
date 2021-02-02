// SPDX-License-Identifier: GPL-2.0-only
///
/// Use zeroing allocator rather than allocator followed by memset with 0
///
/// This considers some simple cases that are common and easy to validate
/// Note in particular that there are no ...s in the rule, so all of the
/// matched code has to be contiguous
///
// Confidence: High
// Copyright: (C) 2009-2010 Julia Lawall, Nicolas Palix, DIKU.
// Copyright: (C) 2009-2010 Gilles Muller, INRIA/LiP6.
// Copyright: (C) 2017 Himanshu Jha
// URL: http://coccinelle.lip6.fr/rules/kzalloc.html
// Options: --no-includes --include-headers
//

virtual context
virtual patch
virtual org
virtual report

//----------------------------------------------------------
//  For context mode
//----------------------------------------------------------

@depends on context && file in "kernel"@
type T, T2, T3;
expression x;
expression E1;
statement S;
@@

* x = (T)malloc(E1);
  if ((x==NULL) || ...) S
(
* (T3)memset_s((T2)x,E1,0,E1);
|
* memset_s((T2)x,E1,0,E1);
)

//----------------------------------------------------------
//  For patch mode
//----------------------------------------------------------

@depends on patch && file in "kernel"@
type T, T2;
expression x;
expression E1;
statement S;
@@

(
- x = malloc(E1);
+ x = zalloc(E1);
|
- x = (T *)malloc(E1);
+ x = (T *)zalloc(E1);
|
- x = (T)malloc(E1);
+ x = (T)zalloc(E1);
)
  if ((x==NULL) || ...) S
- memset_s((T2)x,E1,0,E1);

//----------------------------------------------------------
//  For org mode
//----------------------------------------------------------

@r depends on (org || report) && file in "kernel"@
type T, T2, T3;
expression x;
expression E1;
statement S;
position p;
@@

 x = (T)malloc@p(E1);
 if ((x==NULL) || ...) S
(
 memset((T2)x,E1,0,E1);
|
 (T3)memset((T2)x,E1,0,E1);
)

@script:python depends on org@
p << r.p;
x << r.x;
@@

msg="WARNING: zalloc should be used for %s, instead of malloc/memset_s" % (x)
msg_safe=msg.replace("[","@(").replace("]",")")
coccilib.org.print_todo(p[0], msg_safe)

@script:python depends on report@
p << r.p;
x << r.x;
@@

msg="WARNING: zalloc should be used for %s, instead of malloc/memset_s" % (x)
coccilib.report.print_report(p[0], msg)
