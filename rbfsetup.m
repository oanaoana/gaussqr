% rbfsetup.m
% This file puts the appropriate directories in your path
% This is called a function because I don't want the user to
%   see these internal variables after this is called
%
% DEVELOPER'S NOTE: We should have a separate file for people to introduce
% locally relevant values.
function rbfsetup
thisDir = pwd;
thisOS = system_dependent('getos');
if(strfind(thisOS,'Windows')>0)  % Consider replacing with pathsep
    dirslash = '\';
else
    dirslash = '/';
end

% Define the necessary directories
%
% DEVELOPERS NOTE:
% I should change this so that it can only be called from the GaussQR base
% directory - I don't want someone accidentally changing the paths.  I'll
% have to think about how to do this.
sourceDir = strcat(thisDir,dirslash,'source');
  gaussqrDir = strcat(sourceDir,dirslash,'gaussqr');
    gqrauxiliaryDir = strcat(gaussqrDir,dirslash,'auxiliary');
  utilitiesDir = strcat(sourceDir,dirslash,'utilities');
  maternqrDir = strcat(sourceDir,dirslash,'maternqr');
    mqrauxiliaryDir = strcat(maternqrDir,dirslash,'auxiliary');

examplesDir = strcat(thisDir,dirslash,'examples');
  intexamplesDir = strcat(examplesDir,dirslash,'interpolation');
  apxexamplesDir = strcat(examplesDir,dirslash,'approximation');
  funexamplesDir = strcat(examplesDir,dirslash,'functionality');
  bvpexamplesDir = strcat(examplesDir,dirslash,'bvps');
  fdfexamplesDir = strcat(examplesDir,dirslash,'finitedifferences');
  parexamplesDir = strcat(examplesDir,dirslash,'parameterization');
  dipoleDir = strcat(examplesDir,dirslash,'dipole');
    dipolesourceDir = strcat(dipoleDir,dirslash,'source');
  approxeigsDir = strcat(examplesDir,dirslash,'eig_appx');
otherDir = strcat(thisDir,dirslash,'fromothers');
bookDir = strcat(thisDir,dirslash,'book');
researchDir = genpath(strcat(thisDir,dirslash,'research'));

% Add the directories to the path
addpath(thisDir,sourceDir,gaussqrDir,gqrauxiliaryDir,mqrauxiliaryDir, ...
    utilitiesDir,otherDir,maternqrDir,intexamplesDir,apxexamplesDir, ...
    funexamplesDir,bvpexamplesDir,fdfexamplesDir,parexamplesDir, ...
    dipoleDir,approxeigsDir,dipolesourceDir,bookDir,researchDir, ...
    '-begin');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup global constants and parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global GAUSSQR_PARAMETERS
GAUSSQR_PARAMETERS.BASE_DIRECTORY = thisDir;
GAUSSQR_PARAMETERS.DIRECTORY_SLASH = dirslash;

% This provides access to the gaussqr data directory and files needed to
% run certain examples
% Programmer's Note: We could write this so that all the data is acquired
% the first time rbfsetup is run.  Right now, data is only acquired on an
% as needed basis, which is bad if the user loses internet
% Programmer's Note: There could be a list posted on the gaussqr website of
% all the data files that are available to users, and this queries that
% list when attached to the internet.  That would prevent us from manually
% updating the list here, or perhaps forgetting to, as new data arises.
GAUSSQR_PARAMETERS.WEB_DIRECTORY = 'http://math.iit.edu/~mccomic/gaussqr';
GAUSSQR_PARAMETERS.AVAILABLE_DATA = {'sphereMDpts_data.mat',...
                                     'coverpainting.png',...
                                     'AnimasRiver_data.mat',...
                                     'volcano_data.mat',...
                                     'BigSur_data.mat',...
                                     'glacier_data.mat'};

% Allow for random number reset based on what the right call is
% I'm not sure this is correct ... I feel like rng is builtin
% Also, eventually rand('state') will not work any longer
if exist('rng','file')
    GAUSSQR_PARAMETERS.RANDOM_SEED = @(rseed) rng(rseed);
else
    GAUSSQR_PARAMETERS.RANDOM_SEED = @(rseed) rand('state',rseed);
end

% Alert the user if there is an issue during computation
% Otherwise this info is stored in the GQR object, when possible
GAUSSQR_PARAMETERS.WARNINGS_ON = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Start of optional directory checking, management
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set this value to '/my/picture/directory' so that the function SaveFig
% puts images you want to save in that directory
% This will NOT create this directory for you, if it does not exist, it
% will simply save figures to the gaussqr home directory
% You have to create the directory yourself
% Windows Example: 
GAUSSQR_PARAMETERS.FIGURE_DIRECTORY = 'C:\Users\ironmike\Documents\book\First Draft\Figures';
% GAUSSQR_PARAMETERS.FIGURE_DIRECTORY = 'C:\Users\ironmike\Documents\book\First Draft\Figures';
if not(exist(GAUSSQR_PARAMETERS.FIGURE_DIRECTORY,'dir'))
    if GAUSSQR_PARAMETERS.WARNINGS_ON
        warning('Figure directory %s does not exist; reverting to %s',...
            GAUSSQR_PARAMETERS.FIGURE_DIRECTORY,GAUSSQR_PARAMETERS.BASE_DIRECTORY)
    end
    GAUSSQR_PARAMETERS.FIGURE_DIRECTORY = GAUSSQR_PARAMETERS.BASE_DIRECTORY;
end
% This value is for gqr_savefig, but has not been tested sufficiently
GAUSSQR_PARAMETERS.FIGURE_FONTSIZE = 14;

% Set this value to '/my/data/directory' so that data that needs to be
% downloaded from GaussQR (or elsewhere) can be stored uniformly
% By default this location is '/gaussqr/data'
% This WILL create this directory, if it does not exist
% Windows Example:
GAUSSQR_PARAMETERS.DATA_DIRECTORY = strcat(thisDir,dirslash,'data');
if not(exist(GAUSSQR_PARAMETERS.DATA_DIRECTORY,'dir'))
    [dir_created,message,messageid] = mkdir(GAUSSQR_PARAMETERS.DATA_DIRECTORY);
    if not(dir_created)
        warning('Data directory %s could not be created\nMatlab message %s: %s\nData stored in base GaussQR directory',GAUSSQR_PARAMETERS.DATA_DIRECTORY,messageid,message);
        GAUSSQR_PARAMETERS.DATA_DIRECTORY = thisDir;
    end
end
addpath(GAUSSQR_PARAMETERS.DATA_DIRECTORY);

dirsToCheck = {thisDir,GAUSSQR_PARAMETERS.FIGURE_DIRECTORY,GAUSSQR_PARAMETERS.DATA_DIRECTORY};
for k=1:length(dirsToCheck)
    [dirstat,dirinfo] = fileattrib(dirsToCheck{k});
    if dirstat~=1 || ~dirinfo.UserWrite
        warning('You do not appear to have write permissions to %s',dirsToCheck{k})
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check to see if various toolboxes are available
v = ver;
GAUSSQR_PARAMETERS.CURVEFIT_TOOLBOX_AVAILABLE = any(strcmp('Curve Fitting Toolbox', {v.Name}));
GAUSSQR_PARAMETERS.IMAGEPROC_TOOLBOX_AVAILABLE = any(strcmp('Image Processing Toolbox', {v.Name}));
GAUSSQR_PARAMETERS.NEURALNETWORK_TOOLBOX_AVAILABLE = any(strcmp('Neural Network Toolbox', {v.Name}));
GAUSSQR_PARAMETERS.OPTIMIZATION_TOOLBOX_AVAILABLE = any(strcmp('Optimization Toolbox', {v.Name}));
GAUSSQR_PARAMETERS.STATISTICS_TOOLBOX_AVAILABLE = (any(strcmp('Statistics Toolbox', {v.Name})) | any(strcmp('Statistics and Machine Learning Toolbox', {v.Name})));
GAUSSQR_PARAMETERS.SYMBOLIC_TOOLBOX_AVAILABLE = any(strcmp('Symbolic Math Toolbox', {v.Name}));
GAUSSQR_PARAMETERS.WAVELET_TOOLBOX_AVAILABLE = any(strcmp('Wavelet Toolbox', {v.Name}));

% At what point should the asymptotic approximation to Hermite be used
% Anything between 35-60 you shouldn't be able to tell the difference
% Beyond 70 it's pretty necessary
GAUSSQR_PARAMETERS.HERMITE_ASYMPTOTIC_MIN_INDEX = 40;

% Sets up the polynomial coefficients for later use
GAUSSQR_PARAMETERS.HERMITE_COEFFICIENTS = cell(GAUSSQR_PARAMETERS.HERMITE_ASYMPTOTIC_MIN_INDEX,1);
for k=1:GAUSSQR_PARAMETERS.HERMITE_ASYMPTOTIC_MIN_INDEX
    GAUSSQR_PARAMETERS.HERMITE_COEFFICIENTS{k} = HermitePoly(k-1);
end

% Finds all the Bernoulli numbers which are needed for the Bernoulli
% polynomial computation.  This is only necessary if the symbolic
% toolbox is not available.
% This is only the first 30, for polynomials greater, you need to
% have the symbolic toolbox
%%%% MATERNQR relevant
GAUSSQR_PARAMETERS.BERNOULLI_NUMBERS = [1 -1/2 1/6 0 -1/30 0 1/42 0 -1/30 0 5/66 0 ...
    -691/2730 0 7/6 0 -3617/510 0 43867/798 0 -174611/330 0 854513/138 0 ...
    -236364091/2730 0 8553013/6 0 -23749461029/870 0 8615841276005/14322];

% Parameters which determine how the difference between two
% vectors is computed.
% errstyle : 1 - individual relative RMS error
%            2 - absolute error
%            3 - relative error
%            4 - relative RMS error <default>
% normtype : 1 - sum absolute values
%            2 - sqrt of sum of squares <default>
%            inf - largest absolute value
%%%% MATERNQR relevant
GAUSSQR_PARAMETERS.ERROR_STYLE = 4;
GAUSSQR_PARAMETERS.NORM_TYPE = 2;

% Use logarithms when computing rbfphi
% Shouldn't be an issue unless you have M>200 or x>20
% In general, you should use logs
% Set to 0 to turn off, 1 to turn on
GAUSSQR_PARAMETERS.RBFPHI_WITH_LOGS = 1;

% Tolerance for using asymptotic approximation of exponential within rbfphi
% The term sqrt(1+(2ep/a)^2)-1 pops up, and you can get cancelation
% This will cause the switch to sqrt(1+(2ep/a)^2)-1 = 2(ep/a)^2-2(ep/a)^4
% The switch occurs when (1+(2ep/a)^2)^(1/4)-1<tol
GAUSSQR_PARAMETERS.RBFPHI_EXP_TOL = 1e-4;

% Maximum additional eigenfunctions to add to try to reach optimal accuracy
% Adding more should allow you to spread out the ill-conditioning to more
% functions, but those functions can themselves become ill-conditioned so
% there may be a trade off.
% Choosing 0 means there is no upper bound.
% If you choose a negative number, that is treated as a percentage of the
% number of input points, ie. -50 would mean max M=1.5N
%%%% MATERNQR relevant
GAUSSQR_PARAMETERS.MAX_EXTRA_EFUNC = 200;

% This chooses a default global scale parameter
% You should really set this as you go and not use the default
% This is only here to get you going and will probably be removed
GAUSSQR_PARAMETERS.ALPHA_DEFAULT = sqrt(2);

% Pick a transition point for the ranksolve algorithm to switch between
% directly forming the linear system or solving with the Sherman-Morrison
% formula.
% This value r must be between 0 and 1.
% For M < r*N, Sherman-Morrison will be used
% For M >= r*N, the low-rank portion will be explicitly computed
GAUSSQR_PARAMETERS.RANKSOLVE_PROPORTION = .75;

% Default number of functions to use for regression
% Adding more functions will help the quality of the regression but will
% cost more than a lower r.
% If you choose r>1, this value is the default number of functions to use,
% which will work up to N
% For 0<r<=1, this value M is a proportion of N
GAUSSQR_PARAMETERS.DEFAULT_REGRESSION_FUNC = .5;

% This is the default value for the number of eigenfunctions
% to require orthonormality for when searching for an alpha value.
% This value must be a positive integer
% rbfalphasearch will try to choose the smallest alpha such that all 
GAUSSQR_PARAMETERS.ORTH_INDEX_REQUESTED = 1;

% This is the tolerance to which orthonormality is accepted
% We consider functions orthonormal if
%   abs(1-Integral_n)<tol
% In higher dimensions you will have to give more leeway because the
% integrals are generally all smaller than 1 and their product may be
% significantly less than one.
GAUSSQR_PARAMETERS.DEFAULT_ORTH_TOLERANCE = 3e-2;

% These are the bounds of the alpha search algorithm
% If the acceptable alpha region is outside this, you likely won't find it
% As a general guide, for higher dimensions, you'll need a smaller alpha
% on the same domain
% The minimum value is the starting point for the alpha search, so if you
% have a better value, use it.
GAUSSQR_PARAMETERS.ORTH_MINIMUM_ALPHA = 1e-3;
GAUSSQR_PARAMETERS.ORTH_MAXIMUM_ALPHA = 1e3;

% This determines how accurate the alpha parameter needs to be solved for
% In general this doesn't need to be too accurate because there should be a
% range of acceptable parameters
% This value is passed directly to fminbnd as options.TolX
GAUSSQR_PARAMETERS.ORTH_SEARCH_ACCURACY = 1e-1;

% The accuracy required of quadl in the orthonormality test while computing
% the integration.  The default value for quadl is 1e-6, but you might be
% able to speed up the search by choosing a higher tolerance.  For right
% now this is only used to get a starting point for the optimization
% routine which uses the full 1e-6 tolerance.
GAUSSQR_PARAMETERS.ORTH_INTEGRATION_TOL = 1e-4;

% We use a linear eigenvalue computation to determine the roots of the
% eigenfunctions.  At some point, it is cheaper to only find the largest
% eigenvalue than all the eigenvalues (if that's all you need) using sparse
% eigensolver methods.  This value allows you to determine where you'd like
% to switch between eig(J) and eigs(Jsparse).
% 
% If you are computing all the roots, it will always use eig(J) because it
% is much faster, at least on my laptop.  If you are going to be using a
% large number of points often, maybe consider computing them all once and
% then storing them.  Or maybe I could do that and store up to M=1000 roots
% or so in a binary file in the repo.
GAUSSQR_PARAMETERS.ORTH_ROOT_SPARSE_LIMIT = 500;

% Activate this switch if you want to allow for the fast evaluation of the
% rbfphi function using the recurrence relation.  This is only avaiable
% right now in 1D, and has not been tested for error issues that may arise
% in cancelation.
%
% Also, you cannot use this with derivatives yet, although that won't be
% difficult to implement, I'm just not worried about it yet
GAUSSQR_PARAMETERS.FAST_PHI_EVALUATION = 0;

% Activate this switch to allow storing phi_eval between successive
% evaluations of an interpolant.  The point of this is to allow for the
% user to provide different coefficients but keep eveything else the same
% and not have to recompute phi_eval again.
% 
% This doesn't check to make sure that you haven't changed ep or alpha
% or M, so you could run in to trouble.  I guess I just can't imagine a
% situation where you'd want to evaluate an interpolant with a different ep
% without also conducting a different solve.
%%%% MATERNQR relevant
GAUSSQR_PARAMETERS.STORED_PHI_FOR_EVALUATION = 1;

% This is the tolerance associated with the sobolev function which is the
% kernel of the new operator we are working with.  I don't remember
% what it is, so we'll need to note it here at some point.  This value is
% the ratio of the Mth eigenvalue to the first eigenvalues.  It can roughly
% be used as a tolerance for the accuracy of the function.
%%%% MATERNQR relevant
GAUSSQR_PARAMETERS.SUMMATION_TOLERANCE = 1e-15;

end
