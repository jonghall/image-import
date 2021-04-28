#!/usr/bin/env bash
# create-image-background.sh - A script to convert snapshots to custom images
# Author: Jon Hall
# Copyright (c) 2021
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

source ~/.bash_profile
/root/image-import/create-image.sh >> /var/log/image-process.log 2>&1 &
/root/image-import/create-image.sh >> /var/log/image-process.log 2>&1 &
/root/image-import/create-image.sh >> /var/log/image-process.log 2>&1 &
