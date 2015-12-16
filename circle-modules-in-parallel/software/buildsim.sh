#!/usr/bin/env bash

make -i mem_init_generate

cp mem_init/*.hex ../challengeqsys/testbench/challengeqsys_tb/simulation/submodules/
