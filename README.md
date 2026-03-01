Overview

This project presents a signal processing and machine learning framework for the automated detection of Alzheimer’s Disease (AD) using Electroencephalography (EEG) signals. The system analyzes EEG recordings by decomposing them into standard frequency bands, extracting statistical features, and classifying subjects using a Support Vector Machine (SVM) classifier.

The objective is to develop a computationally efficient and reliable diagnostic pipeline using digital signal processing (DSP) techniques and MATLAB-based implementation.

Motivation

Alzheimer’s Disease is a progressive neurodegenerative disorder that affects brain function, memory, and cognition. EEG provides a non-invasive and cost-effective method to analyze brain activity. Alzheimer’s patients exhibit characteristic changes in EEG signals, particularly slowing of brain rhythms and altered signal complexity.

This project leverages signal processing and machine learning techniques to detect these changes automatically.

Methodology

The implementation consists of four main stages:

1. Signal Acquisition and Preprocessing

EEG dataset includes recordings from Alzheimer’s patients and healthy control subjects.

Signals recorded under eyes-open and eyes-closed conditions.

Difference signal computed to enhance condition-dependent neural activity.

𝑆
𝑑
𝑖
𝑓
𝑓
(
𝑡
)
=
𝑆
𝑜
𝑝
𝑒
𝑛
(
𝑡
)
−
𝑆
𝑐
𝑙
𝑜
𝑠
𝑒
𝑑
(
𝑡
)
S
diff
	​

(t)=S
open
	​

(t)−S
closed
	​

(t)
2. Frequency Band Decomposition

EEG signals were decomposed into five standard frequency bands using FIR band-pass filters designed in MATLAB:

Band	Frequency Range
Delta	0.5 – 4 Hz
Theta	4 – 8 Hz
Alpha	8 – 12 Hz
Beta	12 – 32 Hz
Gamma	32 – 48 Hz

FIR filters were used due to:

Linear phase response

Stability

Preservation of signal morphology

Hardware implementation compatibility

3. Feature Extraction

Hjorth parameters were extracted from each frequency band:

Activity → Signal power (variance)

Mobility → Mean frequency characteristics

Complexity → Signal structural complexity

Total features per subject:

3 parameters × 5 bands = 15 features

These features provide a compact and efficient representation of EEG signal characteristics.

4. Classification using Machine Learning

A Support Vector Machine (SVM) classifier was used for classification.

Validation method:

10-fold cross-validation

Classifier advantages:

High accuracy

Good generalization

Suitable for small datasets

Results

The proposed system achieved:

Accuracy: ~98.6%

Key observations:

Alzheimer’s patients show increased low-frequency activity (Delta, Theta)

Reduced higher frequency activity (Alpha, Beta)

Altered signal complexity compared to healthy subjects

Tools and Technologies

MATLAB

Digital Signal Processing (DSP)

FIR Filter Design

Feature Extraction

Machine Learning (SVM)

Statistical Analysis

System Workflow

EEG Signal
→ Preprocessing
→ FIR Band-pass Filtering
→ Feature Extraction (Hjorth Parameters)
→ Feature Vector Formation
→ SVM Classification
→ Alzheimer’s Detection

Applications

Neurological disorder detection

Biomedical signal analysis

DSP algorithm development

FPGA / hardware implementation of signal processing systems

Clinical diagnostic support systems

Key Learning Outcomes

EEG signal processing and analysis

FIR filter design and implementation

Feature extraction techniques

Machine learning classification

MATLAB-based DSP system design

End-to-end signal processing pipeline development

Future Improvements

FPGA implementation of filtering and feature extraction

Real-time signal processing system

Deep learning-based classification

Larger dataset validation
