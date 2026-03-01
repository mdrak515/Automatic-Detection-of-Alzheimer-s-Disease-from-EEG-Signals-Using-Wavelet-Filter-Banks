# EEG-Based Alzheimer’s Disease Detection using Signal Processing and SVM (MATLAB)

## Overview

This project implements a digital signal processing (DSP) and machine learning pipeline for automated detection of Alzheimer’s Disease (AD) using EEG signals. The system processes EEG recordings, decomposes them into standard frequency bands using FIR band-pass filters, extracts Hjorth parameters as features, and classifies subjects using a Support Vector Machine (SVM).

The implementation is developed in MATLAB with focus on computational efficiency and hardware-compatible signal processing techniques relevant to FPGA and semiconductor systems.

---

## Objectives

- Process EEG signals using digital signal processing techniques  
- Decompose EEG into frequency bands using FIR band-pass filters  
- Extract statistical features using Hjorth parameters  
- Train and evaluate an SVM classifier  
- Develop a complete signal processing and classification pipeline  

---

## System Workflow

EEG Signal  
→ Preprocessing  
→ FIR Band-pass Filtering  
→ Frequency Band Decomposition  
→ Feature Extraction (Hjorth Parameters)  
→ Feature Vector Generation  
→ SVM Classification  
→ Alzheimer’s Detection  

---

## EEG Frequency Bands

| Band | Frequency Range | Significance |
|-----|----------------|-------------|
| Delta | 0.5 – 4 Hz | Deep brain activity |
| Theta | 4 – 8 Hz | Cognitive processing |
| Alpha | 8 – 12 Hz | Relaxed state |
| Beta | 12 – 32 Hz | Active thinking |
| Gamma | 32 – 48 Hz | Higher cognitive functions |

Alzheimer’s Disease typically causes slowing of EEG rhythms and reduced signal complexity.

---

## Feature Extraction

Hjorth Parameters extracted from each band:

- Activity → Signal power (variance)
- Mobility → Frequency characteristics
- Complexity → Signal structural complexity

Total features per subject:

15 features (3 parameters × 5 bands)

---

## Machine Learning Model

Classifier used: Support Vector Machine (SVM)

Validation method:
- 10-fold cross-validation

Performance achieved:

Accuracy: ~98.6%

---

## Repository Structure

EEG-Alzheimer-Detection/

│

├── README.md

├── data/

│   ├── raw/

│   ├── processed/

│

├── matlab/

│   ├── preprocessing.m

│   ├── bandpass_filter.m

│   ├── feature_extraction.m

│   ├── hjorth_parameters.m

│   ├── svm_classifier.m

│   ├── main.m

│

├── results/

│   ├── plots/

│   ├── accuracy_results.mat

│

├── docs/

│   ├── project_report.pdf

│

└── figures/

    ├── eeg_signal.png

    ├── frequency_bands.png

    ├── classification_results.png

---

## Tools and Technologies

- MATLAB
- Digital Signal Processing
- FIR Filter Design
- Machine Learning (SVM)
- Statistical Feature Extraction

---

## Key DSP Techniques Used

- FIR Band-pass Filtering
- Frequency decomposition
- Feature extraction from time-domain signals
- Signal preprocessing and normalization
- Machine learning classification

---

## Applications

- Biomedical signal processing
- Neurological disorder detection
- DSP algorithm development
- FPGA-based signal processing systems
- Hardware implementation of DSP pipelines

---

## Future Improvements

- FPGA implementation using Verilog
- Real-time EEG processing system
- Deep learning classification models
- Larger dataset validation

---

## Author

SK Mahammad Abdullah  
B.E. Electronics and Instrumentation Engineering  
Jadavpur University
