package com.jenisnavadiya.internet_speed_checker

interface TestListener {

    fun onComplete(transferRate: Double)

    fun onError(speedTestError: String, errorMessage: String)

    fun onProgress(percent: Double, transferRate: Double)

}

