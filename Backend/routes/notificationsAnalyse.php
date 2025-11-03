<?php

use Illuminate\Support\Facades\schedule;

schedule::command('comptes:check-non-affectes')->daily();
