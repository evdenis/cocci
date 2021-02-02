// SPDX-License-Identifier: GPL-2.0-only
/// Use kstrdup rather than duplicating its implementation
///
// Confidence: High
// Copyright: (C) 2010-2012 Nicolas Palix.
// Copyright: (C) 2010-2012 Julia Lawall, INRIA/LIP6.
// Copyright: (C) 2010-2012 Gilles Muller, INRIA/LiP6.
// URL: http://coccinelle.lip6.fr/
// Comments:
// Options: --no-includes --include-headers

virtual patch
virtual context
virtual org
virtual report

@depends on patch@
expression from,to;
expression E1;
statement S;
type T;
@@

-  to = (T)malloc(strlen(from) + 1);
+  to = strdup(from);
   ... when != \(from = E1 \| to = E1 \)
   if (to==NULL || ...) S
   ... when != \(from = E2 \| to = E2 \)
-  strcpy(to, from);

@depends on patch@
expression x,from,to;
expression E1,E2,E3;
statement S;
type T;
@@

-   x = strlen(from) + 1;
    ... when != \( x = E1 \| from = E1 \)
-   to = (T)\(malloc\|zalloc\)(x);
+   to = strdup(from);
    ... when != \(x = E2 \| from = E2 \| to = E2 \)
    if (to==NULL || ...) S
    ... when != \(x = E3 \| from = E3 \| to = E3 \)
(
-   memcpy(to, from, x);
|
-   memcpy_s(to, x, from, x);
)

// ---------------------------------------------------------------------

@r1 depends on !patch exists@
expression from,to;
expression E1,E2;
statement S;
position p1,p2;
type T;
@@

*  to = (T)malloc@p1(strlen(from) + 1);
   ... when != \(from = E1 \| to = E1 \)
   if (to==NULL || ...) S
   ... when != \(from = E2 \| to = E2 \)
*  strcpy@p2(to, from);

@r2 depends on !patch exists@
expression x,from,to;
expression E1,E2,E3;
statement S;
position p1,p2;
type T;
@@

*   x = strlen(from) + 1;
    ... when != \( x = E1 \| from = E1 \)
*   to = (T)\(malloc@p1\|zalloc@p1\)(x);
    ... when != \(x = E2 \| from = E2 \| to = E2 \)
    if (to==NULL || ...) S
    ... when != \(x = E3 \| from = E3 \| to = E3 \)
(
*   memcpy@p2(to, from, x);
|
*   memcpy_s@p2(to, x, from, x);
)

@script:python depends on org@
p1 << r1.p1;
p2 << r1.p2;
@@

cocci.print_main("WARNING opportunity for strdup",p1)
cocci.print_secs("strcpy",p2)

@script:python depends on org@
p1 << r2.p1;
p2 << r2.p2;
@@

cocci.print_main("WARNING opportunity for strdup",p1)
cocci.print_secs("memcpy",p2)

@script:python depends on report@
p1 << r1.p1;
p2 << r1.p2;
@@

msg = "WARNING opportunity for strdup (strcpy on line %s)" % (p2[0].line)
coccilib.report.print_report(p1[0], msg)

@script:python depends on report@
p1 << r2.p1;
p2 << r2.p2;
@@

msg = "WARNING opportunity for strdup (memcpy on line %s)" % (p2[0].line)
coccilib.report.print_report(p1[0], msg)
