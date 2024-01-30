export CUDA_VISIBLE_DEVICES=0,1,2,3

MODEL_SIZE=7B
NUM_GPUS=4
BATCH_SIZE_PER_GPU=2
TOTAL_BATCH_SIZE=128
GRADIENT_ACC_STEPS=$(($TOTAL_BATCH_SIZE/$NUM_GPUS/$BATCH_SIZE_PER_GPU))
MODEL_PATH=microsoft/deberta-v3-large
# TRAIN_DATASET=lvwerra/stack-exchange-paired
# EVAL_DATASET=lvwerra/stack-exchange-paired
TRAIN_DATASET=mychen76/stack-exchange-paired-500k
EVAL_DATASET=mychen76/stack-exchange-paired-500k
# MODEL_PATH=/net/nfs.cirrascale/allennlp/yizhongw/hf_llama2_models/${MODEL_SIZE}
OUTPUT_DIR=test-models/
# OUTPUT_DIR=net/nfs.cirrascale/allennlp/jacobm/modular_adaptation/checkpoints/${DATASET}_${MODEL_SIZE}/
echo "Training llama model ${MODEL_SIZE} using $NUM_GPUS GPUs, $BATCH_SIZE_PER_GPU batch size per GPU, $GRADIENT_ACC_STEPS gradient accumulation steps"

accelerate launch \
    --mixed_precision bf16 \
    --num_machines 1 \
    --num_processes $NUM_GPUS \
    --use_deepspeed \
    --deepspeed_config_file ds_configs/stage3_no_offloading_accelerate.conf \
    scripts/train_rm.py \
    --model_name_or_path $MODEL_PATH \
    --tokenizer_name $MODEL_PATH \
    --use_slow_tokenizer \
    --dataset_name $TRAIN_DATASET \
    --max_seq_length 2048 \
    --preprocessing_num_workers 16 \
    --per_device_train_batch_size $BATCH_SIZE_PER_GPU \
    --gradient_accumulation_steps $GRADIENT_ACC_STEPS \
    --learning_rate 2e-5 \
    --lr_scheduler_type linear \
    --warmup_ratio 0.03 \
    --weight_decay 0. \
    --num_train_epochs 2 \
    --output_dir / \
    --with_tracking \
    --report_to tensorboard \
    --logging_steps 1

    # --use_flash_attn \