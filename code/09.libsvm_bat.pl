#!/usr/bin/perl 

use strict;
use warnings;

my ($learn, $test) = @ARGV;

#system(qq[perl 05.learn_to_libsvm_train.pl $learn]);

#system(qq[svm-train -h 0 $learn.libsvm.train $learn.libsvm.model]);
#system(qq[svm-predict $learn.libsvm.train $learn.libsvm.model $learn.libsvm.trainout]);
#system(qq[perl 07.shrink_svm_out_type_to_csv.pl $learn $learn.libsvm.trainout $learn.libsvm.type "predict_type"]);
system(qq[perl 08.merge_predict_qcnt.pl $learn.libsvm.out.predict.csv client_qcnt.csv client_qtype/client_A_secdom.csv]);

#system(qq[perl 06.shrink_to_libsvm_test.pl $test]);
#system(qq[svm-predict $test.libsvm.test $learn.libsvm.model $test.libsvm.out]);
#system(qq[perl 07.shrink_svm_out_type_to_csv.pl $test $test.libsvm.out $learn.libsvm.type "predict_type"]);
system(qq[perl 08.merge_predict_qcnt.pl $test.libsvm.out.predict.csv client_qcnt.csv client_qtype/client_A_secdom.csv]);
