package com.example.greenchoice

import android.content.res.AssetManager
import org.pytorch.IValue
import org.pytorch.Module
import org.pytorch.Tensor
import java.nio.FloatBuffer

class PyTorchModel(private val assetManager: AssetManager) {
    private lateinit var module: Module

    fun loadModel(modelPath: String) {
        module = Module.load(modelPath)
    }

    fun runInference(inputTensor: FloatArray): FloatArray {
        val inputTensor = Tensor.fromBlob(inputTensor, longArrayOf(1, 3, 224, 224))
        val outputTensor = module.forward(IValue.from(inputTensor)).toTensor()
        return outputTensor.dataAsFloatArray
    }
}
