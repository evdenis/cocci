// SPDX-License-Identifier: GPL-2.0-only
/// NULL check before some freeing functions is not needed.
// Copyright: (C) 2014 Fabian Frederick.
// Comments: -
// Options: --no-includes --include-headers

virtual patch
virtual org
virtual report
virtual context

@r2 depends on patch@
expression E1, E2;
@@

- if (E1 != NULL)
(
  free(E1);
|
  (void)LOS_MemFree(E2, E1);
//|
//  (VOID)LOS_MemFree(E2, E1);
)

@r depends on context || report || org @
expression E1, E2;
position p;
@@

* if (E1 != NULL)
(
*  free@p(E1);
|
*  (void)LOS_MemFree@p(E2, E1);
//|
//*  (VOID)LOS_MemFree@p(E2, E1);
)

@script:python depends on org@
p << r.p;
@@

cocci.print_main("NULL check before that freeing function is not needed", p)

@script:python depends on report@
p << r.p;
@@

msg = "WARNING: NULL check before some freeing functions is not needed."
coccilib.report.print_report(p[0], msg)
