function [options,K,patches,tau,p] = setExVivo(sizY,fr,tsub)

    patch_size = [128,128];                 % size of each patch along each dimension (optional, default: [32,32])
    overlap = [32,32];                      % amount of overlap in each dimension (optional, default: [4,4])
    
    patches = construct_patches(sizY(1:end-1),patch_size,overlap);
    K = 50;                                           % number of components to be found
    tau = 16;                                          % std of gaussian kernel (half size of neuron), 8
    p = 2;                                            % order of autoregressive system (p = 0 no dynamics, p=1 just decay, p = 2, both rise and decay)
    merge_thr = 0.8;                                  % merging threshold, 0.8
    
    options = CNMFSetParms(...
        'd1',sizY(1),'d2',sizY(2),...
        'deconv_method','constrained_foopsi',...    % neural activity deconvolution method
        'p',p,...                                   % order of calcium dynamics
        'ssub',1,...                                % spatial downsampling when processing
        'tsub',1,...                                % further temporal downsampling when processing
        'merge_thr',merge_thr,...                   % merging threshold
        'gSig',tau,...
        'max_size_thr',5000,'min_size_thr',25,...   % max/min acceptable size for each component
        'spatial_method','regularized',...          % method for updating spatial components
        'df_prctile',50,...                         % take the median of background fluorescence to compute baseline fluorescence
        'fr',fr/tsub,...                            % downsamples
        'space_thresh',0.35,...                     % space correlation acceptance threshold
        'min_SNR',2.0,...                           % trace SNR acceptance threshold
        'cnn_thr',0.2,...                           % cnn classifier acceptance threshold
        'nb',1,...                                  % number of background components per patch
        'gnb',1,...                                 % number of global background components
        'decay_time',0.5...                         % length of typical transient for the indicator used
        );
    
end