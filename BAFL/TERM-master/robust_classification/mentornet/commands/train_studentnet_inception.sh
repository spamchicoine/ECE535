# Copyright 2018 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
#!/bin/bash

# Inception model is small so train and test on a single GPU.
# The following scripts assumes there are at least 8 GPUs on the machine.
# Otherwise you need to change the device ID and run them on different machines.
# ==============================================================================
#                              Baseline
# ==============================================================================
# CIFAR-10

python code/cifar_train_baseline.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/0.8 \
  --train_log_dir=cifar_models/cifar10/inception/0.8/random/train \
  --num_epochs_per_decay=200 --learning_rate_decay_factor=0.1 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=2 > 0.8_random 2>&1 &


python code/cifar_eval.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/val/ \
  --checkpoint_dir=cifar_models/cifar10/inception/0.2/random/train \
  --eval_dir=cifar_models/cifar10/inception/0.2/random/eval_val \
  --studentnet=inception --device_id=7 >stdout1.txt 2>stderr1.txt &

python code/cifar_train_baseline.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/0.4 \
  --train_log_dir=cifar_models/cifar10/inception/0.4/baseline/train \
  --num_epochs_per_decay=200 --learning_rate_decay_factor=0.1 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=1 >stdout2.txt 2>stderr2.txt &

python code/cifar_train_gce.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/0.2 \
  --train_log_dir=cifar_models/cifar10/inception/0.2/gce/q0.8 \
  --num_epochs_per_decay=200 \
  --learning_rate=0.1 \
  --learning_rate_decay_factor=0.1 \
  --q=0.8 \
  --batch_size=128 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=0 > 0.2_q_0.8 2>&1 &

python code/cifar_train_gce.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/0.4 \
  --train_log_dir=cifar_models/cifar10/inception/0.4/gce/q1.0 \
  --num_epochs_per_decay=200 \
  --learning_rate=0.1 \
  --learning_rate_decay_factor=0.1 \
  --q=1.0 \
  --batch_size=128 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=2 > 0.4_q_1.0 2>&1 &

python code/cifar_train_tilting.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/0.8 \
  --train_log_dir=cifar_models/cifar10/inception/0.8/tilting/dynamic_t_-0.5_-2_run2 \
  --num_epochs_per_decay=200 \
  --learning_rate=0.1 \
  --learning_rate_decay_factor=0.1 \
  --tilting=-2 \
  --batch_size=128 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=5 > 0.8_dynamic_t_-0.5_-2_run2 2>&1 &

python code/cifar_train_tilting.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/0.8 \
  --train_log_dir=cifar_models/cifar10/inception/0.8/tilting/train_tmp \
  --num_epochs_per_decay=200 \
  --learning_rate=0.01 \
  --learning_rate_decay_factor=0.1 \
  --tilting -0.5 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=7

python code/cifar_train_tilting2.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/0.8 \
  --train_log_dir=cifar_models/cifar10/inception/0.8/tilting/train_tmp \
  --num_epochs_per_decay=200 \
  --learning_rate=0.01 \
  --learning_rate_decay_factor=0.1 \
  --tilting -0.5 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=6

python code/cifar_eval.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/val/ \
  --checkpoint_dir=cifar_models/cifar10/inception/0.4/tilting/train_t-0.1 \
  --eval_dir=cifar_models/cifar10/inception/0.4/tilting/eval_val \
  --studentnet=inception --device_id=1 >stdout_t-0.1.txt 2>stderr_t-0.1.txt &

python code/cifar_train_tilting.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/0.8 \
  --tilting -0.5 \
  --train_log_dir=cifar_models/cifar10/inception/0.8/tilting/train_t-0.5_lr \
  --num_epochs_per_decay=200 --learning_rate_decay_factor=0.1 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=1 >stdout_0.8_t-0.5.txt 2>stderr_0.8_t-0.5.txt &

python code/cifar_eval.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/val/ \
  --checkpoint_dir=cifar_models/cifar10/inception/0.8/tilting/dynamic_t_-0.5_-2_run2 \
  --eval_dir=cifar_models/cifar10/inception/0.8/tilting/eval_val \
  --studentnet=inception --device_id=7

python code/cifar_eval.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/val/ \
  --checkpoint_dir=cifar_models/cifar10/inception/0.4/baseline/train \
  --eval_dir=cifar_models/cifar10/inception/0.4/baseline/eval_val \
  --studentnet=inception --device_id=1 >stdout3.txt 2>stderr3.txt &

python code/cifar_train_baseline.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/0.8 \
  --train_log_dir=cifar_models/cifar10/inception/0.8/baseline/train \
  --num_epochs_per_decay=200 --learning_rate_decay_factor=0.1 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=2 >stdout4.txt 2>stderr4.txt &

python code/cifar_eval.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/val/ \
  --checkpoint_dir=cifar_models/cifar10/inception/0.8/baseline/train \
  --eval_dir=cifar_models/cifar10/inception/0.8/baseline/eval_val \
  --studentnet=inception --device_id=2 >stdout7.txt 2>stderr7.txt &


# ==============================================================================
#                          Self-paced MentorNet
# ==============================================================================
# CIFAR-10
python code/cifar_train_mentornet.py --dataset_name=cifar10 \
  --trained_mentornet_dir=mentornet_models/models/self_paced/self_paced_mentornet \
  --loss_p_precentile=0.7 \
  --nofixed_epoch_after_burn_in \
  --burn_in_epoch=0 \
  --example_dropout_rates="0.0,100" \
  --data_dir=data/cifar10/0.0 \
  --train_log_dir=cifar_models/cifar10/inception/0.0/selfpaced/train2 \
  --num_epochs_per_decay=200 --learning_rate_decay_factor=0.1 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=6 > 0.0_self_paced_run2 2>&1 &

python code/cifar_eval.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/val/ \
  --checkpoint_dir=cifar_models/cifar10/inception/0.2/selfpaced/train \
  --eval_dir=cifar_models/cifar10/inception/0.2/selfpaced/eval_val \
  --studentnet=inception --device_id=0 >stdout1.txt 2>stderr1.txt &

python code/cifar_train_mentornet.py --dataset_name=cifar10 \
  --trained_mentornet_dir=mentornet_models/models/self_paced/self_paced_mentornet \
  --loss_p_precentile=0.7 \
  --nofixed_epoch_after_burn_in \
  --burn_in_epoch=0 \
  --example_dropout_rates="0.0,100" \
  --data_dir=data/cifar10/0.4 \
  --train_log_dir=cifar_models/cifar10/inception/0.4/selfpaced/train \
  --num_epochs_per_decay=200 --learning_rate_decay_factor=0.1 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=1 >stdout2.txt 2>stderr2.txt &

python code/cifar_eval.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/val/ \
  --checkpoint_dir=cifar_models/cifar10/inception/0.4/selfpaced/train \
  --eval_dir=cifar_models/cifar10/inception/0.4/selfpaced/eval_val \
  --studentnet=inception --device_id=1 >stdout3.txt 2>stderr3.txt &

python code/cifar_train_mentornet.py --dataset_name=cifar10 \
  --trained_mentornet_dir=mentornet_models/models/self_paced/self_paced_mentornet \
  --loss_p_precentile=0.7 \
  --nofixed_epoch_after_burn_in \
  --burn_in_epoch=0 \
  --example_dropout_rates="0.0,100" \
  --data_dir=data/cifar10/0.8 \
  --train_log_dir=cifar_models/cifar10/inception/0.8/selfpaced/train \
  --num_epochs_per_decay=200 --learning_rate_decay_factor=0.1 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=2 >stdout4.txt 2>stderr4.txt &

python code/cifar_eval.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/val/ \
  --checkpoint_dir=cifar_models/cifar10/inception/0.8/selfpaced/train \
  --eval_dir=cifar_models/cifar10/inception/0.8/selfpaced/eval_val \
  --studentnet=inception --device_id=2 >stdout5.txt 2>stderr5.txt &


# ==============================================================================
#                          Focal Loss MentorNet
# ==============================================================================
# CIFAR-10
python code/cifar_train_mentornet.py --dataset_name=cifar10 \
  --trained_mentornet_dir=mentornet_models/models/focal_loss/focal_loss_mentornet \
  --loss_p_precentile=0.7 \
  --nofixed_epoch_after_burn_in \
  --burn_in_epoch=0 \
  --example_dropout_rates="0.0,100" \
  --data_dir=data/cifar10/0.2 \
  --train_log_dir=cifar_models/cifar10/inception/0.2/focalloss/train \
  --num_epochs_per_decay=200 --learning_rate_decay_factor=0.1 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=0 >stdout0.txt 2>stderr0.txt &

python code/cifar_eval.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/val/ \
  --checkpoint_dir=cifar_models/cifar10/inception/0.2/focalloss/train \
  --eval_dir=cifar_models/cifar10/inception/0.2/focalloss/eval_val \
  --studentnet=inception --device_id=0 >stdout1.txt 2>stderr1.txt &

python code/cifar_train_mentornet.py --dataset_name=cifar10 \
  --loss_p_precentile=0.7 \
  --nofixed_epoch_after_burn_in \
  --burn_in_epoch=0 \
  --example_dropout_rates="0.0,100" \
  --data_dir=data/cifar10/0.4 \
  --train_log_dir=cifar_models/cifar10/inception/0.4/focalloss/train \
  --num_epochs_per_decay=200 --learning_rate_decay_factor=0.1 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=2 >stdout_fl.txt 2>stderr_fl.txt &

python code/cifar_eval.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/val/ \
  --checkpoint_dir=cifar_models/cifar10/inception/0.4/focalloss/train \
  --eval_dir=cifar_models/cifar10/inception/0.4/focalloss/eval_val \
  --studentnet=inception --device_id=1 >stdout3.txt 2>stderr3.txt &

python code/cifar_train_mentornet.py --dataset_name=cifar10 \
  --loss_p_precentile=0.7 \
  --nofixed_epoch_after_burn_in \
  --burn_in_epoch=0 \
  --example_dropout_rates="0.0,100" \
  --data_dir=data/cifar10/0.8 \
  --train_log_dir=cifar_models/cifar10/inception/0.8/focalloss/train \
  --num_epochs_per_decay=200 --learning_rate_decay_factor=0.1 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=5 >stdout_0.8_fl.txt 2>stderr_0.8_fl.txt &

python code/cifar_eval.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/val/ \
  --checkpoint_dir=cifar_models/cifar10/inception/0.8/focalloss/train \
  --eval_dir=cifar_models/cifar10/inception/0.8/focalloss/eval_val \
  --studentnet=inception --device_id=2 >stdout5.txt 2>stderr5.txt &


# ==============================================================================
#                          MentorNet PD
# ==============================================================================
# CIFAR-10
python code/cifar_train_mentornet.py --dataset_name=cifar10 \
  --trained_mentornet_dir=mentornet_models/models/mentornet_pd1_g_1/mentornet_pd \
  --loss_p_precentile=0.75 \
  --nofixed_epoch_after_burn_in \
  --burn_in_epoch=0 \
  --example_dropout_rates="0.5,17,0.05,83" \
  --data_dir=data/cifar10/0.2 \
  --train_log_dir=cifar_models/cifar10/inception/0.2/mentornet_pd1_g_1/train \
  --num_epochs_per_decay=200 --learning_rate_decay_factor=0.1 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=0 >stdout0.txt 2>stderr0.txt &

python code/cifar_eval.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/val/ \
  --checkpoint_dir=cifar_models/cifar10/inception/0.2/mentornet_pd1_g_1/train \
  --eval_dir=cifar_models/cifar10/inception/0.2/mentornet_pd1_g_1/eval_val \
  --studentnet=inception --device_id=0 >stdout1.txt 2>stderr1.txt &

python code/cifar_train_mentornet.py --dataset_name=cifar10 \
  --trained_mentornet_dir=mentornet_models/models/mentornet_pd1_g_1/mentornet_pd \
  --loss_p_precentile=0.75 \
  --nofixed_epoch_after_burn_in \
  --burn_in_epoch=0 \
  --example_dropout_rates="0.5,17,0.05,83" \
  --data_dir=data/cifar10/0.4 \
  --train_log_dir=cifar_models/cifar10/inception/0.4/mentornet_pd1_g_1/train \
  --num_epochs_per_decay=200 --learning_rate_decay_factor=0.1 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=1 >stdout2.txt 2>stderr2.txt &

python code/cifar_eval.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/val/ \
  --checkpoint_dir=cifar_models/cifar10/inception/0.4/mentornet_pd1_g_1/train \
  --eval_dir=cifar_models/cifar10/inception/0.4/mentornet_pd1_g_1/eval_val \
  --studentnet=inception --device_id=1 >stdout3.txt 2>stderr3.txt &

python code/cifar_train_mentornet.py --dataset_name=cifar10 \
  --trained_mentornet_dir=mentornet_models/models/mentornet_pd1_g_1/mentornet_pd \
  --loss_p_precentile=0.5 \
  --nofixed_epoch_after_burn_in \
  --burn_in_epoch=0 \
  --example_dropout_rates="0.5,17,0.05,83" \
  --data_dir=data/cifar10/0.8 \
  --train_log_dir=cifar_models/cifar10/inception/0.8/mentornet_pd1_g_1/train \
  --num_epochs_per_decay=200 --learning_rate_decay_factor=0.1 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=2 >stdout4.txt 2>stderr4.txt &

python code/cifar_eval.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/val/ \
  --checkpoint_dir=cifar_models/cifar10/inception/0.8/mentornet_pd1_g_1/train \
  --eval_dir=cifar_models/cifar10/inception/0.8/mentornet_pd1_g_1/eval_val \
  --studentnet=inception --device_id=2 >stdout5.txt 2>stderr5.txt &


# ==============================================================================
#                          MentorNet DD
# ==============================================================================
# CIFAR-10
python code/cifar_train_mentornet.py --dataset_name=cifar10 \
  --trained_mentornet_dir=mentornet_models/models/nl_0.2_percentile_90/mentornet_dd \
  --loss_p_precentile=0.8 \
  --fixed_epoch_after_burn_in \
  --burn_in_epoch=18 \
  --example_dropout_rates="0.5,17,0.05,83" \
  --data_dir=data/cifar10/0.2 \
  --train_log_dir=cifar_models/cifar10/inception/0.2/mentornet_dd1/train \
  --num_epochs_per_decay=200 --learning_rate_decay_factor=0.1 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=0 >stdout0.txt 2>stderr0.txt &

python code/cifar_eval.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/val/ \
  --checkpoint_dir=cifar_models/cifar10/inception/0.2/mentornet_dd1/train \
  --eval_dir=cifar_models/cifar10/inception/0.2/mentornet_dd1/eval_val \
  --studentnet=inception --device_id=0 >stdout1.txt 2>stderr1.txt &

python code/cifar_train_mentornet.py --dataset_name=cifar10 \
  --trained_mentornet_dir=mentornet_models/models/nl_0.2_percentile_90/mentornet_dd \
  --loss_p_precentile=0.6 \
  --fixed_epoch_after_burn_in \
  --burn_in_epoch=18 \
  --example_dropout_rates="0.5,17,0.05,83" \
  --data_dir=data/cifar10/0.4 \
  --train_log_dir=cifar_models/cifar10/inception/0.4/mentornet_dd1/train \
  --num_epochs_per_decay=200 --learning_rate_decay_factor=0.1 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=1 >stdout2.txt 2>stderr2.txt &

python code/cifar_eval.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/val/ \
  --checkpoint_dir=cifar_models/cifar10/inception/0.4/mentornet_dd1/train \
  --eval_dir=cifar_models/cifar10/inception/0.4/mentornet_dd1/eval_val \
  --studentnet=inception --device_id=1 >stdout3.txt 2>stderr3.txt &

python code/cifar_train_mentornet.py --dataset_name=cifar10 \
  --trained_mentornet_dir=mentornet_models/models/nl_0.2_percentile_90/mentornet_dd \
  --loss_p_precentile=0.5 \
  --fixed_epoch_after_burn_in \
  --burn_in_epoch=18 \
  --example_dropout_rates="0.5,17,0.05,83" \
  --data_dir=data/cifar10/0.8 \
  --train_log_dir=cifar_models/cifar10/inception/0.8/mentornet_dd1/train \
  --num_epochs_per_decay=200 --learning_rate_decay_factor=0.1 \
  --studentnet=inception --max_number_of_steps=120000 --device_id=2 >stdout4.txt 2>stderr4.txt &

python code/cifar_eval.py --dataset_name=cifar10 \
  --data_dir=data/cifar10/val/ \
  --checkpoint_dir=cifar_models/cifar10/inception/0.8/mentornet_dd1/train \
  --eval_dir=cifar_models/cifar10/inception/0.8/mentornet_dd1/eval_val \
  --studentnet=inception --device_id=2 >stdout5.txt 2>stderr5.txt &

