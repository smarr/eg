#!/bin/sh
#
# Copyright (c) 2007 Shawn O. Pearce
#

test_description='git apply -p handling.'

. ./test-lib.sh

test_expect_success setup '
	mkdir sub &&
	echo A >sub/file1 &&
	cp sub/file1 file1.saved &&
	git add sub/file1 &&
	echo B >sub/file1 &&
	git diff --unstaged >patch.file &&
	git checkout -- sub/file1 &&
	git mv sub süb &&
	echo B >süb/file1 &&
	git diff --unstaged >patch.escaped &&
	grep "[\]" patch.escaped &&
	rm süb/file1 &&
	rmdir süb
'

test_expect_success 'apply git diff with -p2' '
	cp file1.saved file1 &&
	git apply -p2 patch.file
'

test_expect_success 'apply with too large -p' '
	cp file1.saved file1 &&
	test_must_fail git apply --stat -p3 patch.file 2>err &&
	grep "removing 3 leading" err
'

test_expect_success 'apply (-p2) traditional diff with funny filenames' '
	cat >patch.quotes <<-\EOF &&
	diff -u "a/"sub/file1 "b/"sub/file1
	--- "a/"sub/file1
	+++ "b/"sub/file1
	@@ -1 +1 @@
	-A
	+B
	EOF
	echo B >expected &&

	cp file1.saved file1 &&
	git apply -p2 patch.quotes &&
	test_cmp expected file1
'

test_expect_success 'apply with too large -p and fancy filename' '
	cp file1.saved file1 &&
	test_must_fail git apply --stat -p3 patch.escaped 2>err &&
	grep "removing 3 leading" err
'

test_done
