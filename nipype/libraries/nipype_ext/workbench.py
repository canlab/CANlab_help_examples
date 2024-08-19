from nipype.interfaces.workbench import base as wb
from nipype.interfaces.base import BaseInterface, BaseInterfaceInputSpec, traits, File, Str, isdefined, TraitedSpec, CommandLineInputSpec
from traits.api import List

# convert cifti to nifti and back
# this interface was drafted by ChatGPT then heavily modified by BP.
class CiftiConvertNiftiInputSpec(CommandLineInputSpec):
    to_nifti = traits.Bool(True,
        argstr="-to-nifti",
        position=0,
        usedefault=True,
        desc="Convert to NIFTI")

    cifti_in = File(
        desc="The input CIFTI file",
        exists=True,
        argstr="%s",
        position=1,
        mandatory=True,
        requires=['to_nifti']
    )
    nifti_out = File(
        desc="The output NIFTI file",
        argstr="%s",
        position=2,
        genfile=True,
        requires=['to_nifti']
    )
    smaller_file = traits.Bool(
        desc="Use better-fitting dimension lengths",
        argstr="-smaller-file",
        position=3,
        requires=['to_nifti']
    )
    smaller_dims = traits.Bool(
        desc="Minimize the largest dimension",
        argstr="-smaller-dims",
        position=4,
        requires=['to_nifti']
    )


class CiftiConvertNiftiOutputSpec(TraitedSpec):
    out_file = File(
        desc="The converted file",
        exists=True
    )


class CiftiConvertNifti(wb.WBCommand):
    input_spec = CiftiConvertNiftiInputSpec
    output_spec = CiftiConvertNiftiOutputSpec
    _cmd = 'wb_command -cifti-convert'

    def _check_required_inputs(self):
        """Ensure required inputs are in place based on the conversion direction."""
        super(CiftiConvertNifti, self)._check_required_inputs()
        if not isdefined(self.inputs.cifti_in):
            raise ValueError("cifti_in is required when to_nifti is True")
        if not isdefined(self.inputs.nifti_out):
            self.inputs.nifti_out = self._gen_filename('nifti_out')

    def _list_outputs(self):

        outputs = self.output_spec().get()
        if not isdefined(self.inputs.nifti_out):
            self.inputs.nifti_out = self._gen_filename('nifti_out')
        outputs['out_file'] = self.inputs.nifti_out

        return outputs

    def _gen_filename(self, name):
        import os

        if name == 'nifti_out':
            if not isdefined(self.inputs.nifti_out):
                fname, _ = os.path.splitext(os.path.basename(self.inputs.cifti_in))
                fname, _ = os.path.splitext(fname)
                return os.path.join(os.getcwd(), fname + '.nii')
            return self.inputs.nifti_out


# convert cifti to nifti and back
# this interface was drafted by ChatGPT then heavily modified by BP.
class NiftiConvertCiftiInputSpec(CommandLineInputSpec):
    from_nifti = traits.Bool(True,
        argstr="-from-nifti",
        position=0,
        usedefault=True,
        desc="Convert to NIFTI")

    nifti_in = File(
        desc="The input NIFTI file",
        exists=True,
        argstr="%s",
        position=1,
        mandatory=True,
        requires=['from_nifti']
    )
    cifti_template = File(
        desc="The CIFTI file with the dimension(s) and mapping(s) to be used",
        exists=True,
        argstr="%s",
        position=2,
        requires=['from_nifti']
    )
    cifti_out = File(
        desc="The output CIFTI file",
        argstr="%s",
        position=3,
        genfile=True,
        requires=['from_nifti']
    )
    # reset timepoints would go here if you decide to introduce it
    reset_scalars = traits.Bool(
        desc="reset mapping along rows to scalars, taking length from the nifti file",
        argstr="-reset-scalars",
        position=-1,
        requires=['from_nifti']
    )

class NiftiConvertCiftiOutputSpec(TraitedSpec):
    out_file = File(
        desc="The converted file",
        exists=True
    )

class NiftiConvertCifti(wb.WBCommand):
    input_spec = NiftiConvertCiftiInputSpec
    output_spec = NiftiConvertCiftiOutputSpec
    _cmd = 'wb_command -cifti-convert'

    def _check_required_inputs(self):
        """Ensure required inputs are in place based on the conversion direction."""
        super(CiftiConvertNifti, self)._check_required_inputs()
        if not isdefined(self.inputs.nifti_in):
            raise ValueError("nifti_in is required when from_nifti is True")
        if not isdefined(self.inputs.cifti_template):
            raise ValueError("cifti_template is required when from_nifti is True")
        if not isdefined(self.inputs.cifti_out):
            self.inputs.cifti_out = self._gen_filename('cifti_out')

    def _list_outputs(self):

        outputs = self.output_spec().get()

        if not isdefined(self.inputs.cifti_out):
            self.inputs.cifti_out = self._gen_filename('cifti_out')
        outputs['out_file'] = self.inputs.cifti_out

        return outputs

    def _gen_filename(self, name):
        import os

        if name == 'cifti_out':
            if not isdefined(self.inputs.cifti_out):
                fname, _ = os.path.splitext(os.path.basename(self.inputs.nifti_in))
                fname, _ = os.path.splitext(fname)

                _fname, ext1 = os.path.splitext(os.path.basename(self.inputs.cifti_template))
                _, ext2 = os.path.splitext(_fname)

                return os.path.join(os.getcwd(), fname + ext2 + ext1)
            return self.inputs.nifti_out



# convert cifti to nifti and back
# Note: this is a quick and dirty implementation. It is not as fexible
# as the wb_command CLI. It's specifically designed to work with scenarios
# where an HCP style cifti needs to be separated. If surfaces or volumes differ
# this could break (e.g. if you have cerebellar surfaces) without additional
# mods
class CiftiSeparateInputSpec(CommandLineInputSpec):
    in_file=File(
        desc="The cifti to ceparate a component of",
        exists=True,
        argstr="%s",
        position=0,
        mandatory=True,
    )

    direction=traits.Enum('COLUMN','ROW', argstr='%s', position=1,
        usedefault=True,
        desc="which direction to separate into components, ROW or COLUMN")

    volume_all=traits.Bool(False,
        desc=('separate all volume structures into a volume file. '
              'Populates volume_all_out, roi_all_out and label_all_out output fields'),
        argstr='', # this will be populated automatically by _format_arg()
        position=2,
        usedefault=True)

    # this needs
    # note that this logic could be adapted for a -volume argument too (for more granular control than volume-all)
    metric=traits.List(traits.Str,
        desc=('list of structures to output. ',
              'CORTEX_LEFT or CORTEX_RIGHT are sensible. ',
              'See wb_command -cifti-separate for more details'),
        argstr='',
        position=3)


class CiftiSeparateOutputSpec(TraitedSpec):
    volume_all_out=traits.Either(File(), None)
    volume_all_roi_out=traits.Either(File(), None)
    volume_all_label_out=traits.Either(File(), None)
    CORTEX_LEFT_out=traits.Either(File(), None)
    CORTEX_RIGHT_out=traits.Either(File(), None)


class CiftiSeparate(wb.WBCommand):
    input_spec = CiftiSeparateInputSpec
    output_spec = CiftiSeparateOutputSpec


    _cmd = 'wb_command -cifti-separate'
    metric_files = dict()

    def _format_arg(self, name, spec, value):
        import os

        if name == 'volume_all':
            cwd = os.getcwd()
            fname, _ = os.path.splitext(os.path.basename(self.inputs.in_file))
            fname, _ = os.path.splitext(fname)
            return '-volume-all {0} -roi {1} -label {2}'.format(
                        os.path.join(cwd, fname + '_volume_all.nii.gz'),
                        os.path.join(cwd, fname + '_volume_all_roi.nii.gz'),
                        os.path.join(cwd, fname + '_volume_all_label.nii.gz'))
        if name == 'metric':
            return ' '.join(self._format_metric_arg(v) for v in value)
        return super(CiftiSeparate, self)._format_arg(name, spec, value)

    def _format_metric_arg(self, structure):
        import os

        fname, _ = os.path.splitext(os.path.basename(self.inputs.in_file))
        fname, _ = os.path.splitext(fname)

        filename = os.path.join(os.getcwd(), fname + '_' + structure + '.func.gii')
        self.metric_files[structure] = filename

        return "-metric {} {}".format(structure, filename)

    def _list_outputs(self):
        import os

        outputs = self.output_spec().get()

        if self.inputs.volume_all:
            cwd = os.getcwd();
            fname, _ = os.path.splitext(os.path.basename(self.inputs.in_file))
            fname, _ = os.path.splitext(fname)

            outputs['volume_all_out'] = os.path.join(cwd, fname + '_volume_all.nii.gz')
            outputs['volume_all_roi_out'] = os.path.join(cwd, fname + '_volume_all_roi.nii.gz')
            outputs['volume_all_label_out'] = os.path.join(cwd, fname + '_volume_all_label.nii.gz')

        if isdefined(self.inputs.metric):
            for structure in self.metric_files:
                outputs[structure + '_out'] = self.metric_files[structure]

        return outputs


# Note: this is another quick and dirty implementation. It is not as fexible
# as the wb_command CLI. It's specifically designed to work with scenarios
# where an HCP style cifti needs to be merged. If surfaces or volumes differ
# this could break (e.g. if you have cerebellar surfaces) without additional
# mods
class CiftiCreateDenseTimeseriesInputSpec(CommandLineInputSpec):
    out_file=File(
        argstr='%s',
        position=0,
        genfile=True,
        desc="the output cifti file. Autogenerated if not specified."
    )

    volume=File(
        exists=True,
        desc='volume_file containing all voxel data for all volume structures',
        argstr="-volume %s",
        position=1,
        requires=['volume_label'])

    volume_label=File(
        exists=True,
        desc='label volume file containing labels for cifti structures',
        argstr="%s",
        position=2,
        requires=['volume'])

    left_metric=File(
        exists=True,
        desc="metric for left surface",
        argstr="-left-metric %s",
        position=3)

    left_roi=File(
        exists=True,
        desc="roi of vertices to use from left surface as a metric file",
        argstr="-roi-left %s",
        position=4,
        requires=['left_metric'])

    right_metric=File(
        exists=True,
        desc="metric for the right surface",
        argstr="-right-metric %s",
        position=5)

    right_roi=File(
        exists=True,
        desc="roi of vertices to use from right surface as a metric file",
        argstr="-roi-right %s",
        position=6,
        requires=['right_metric'])

    # cerebellum can be incorporated by copying the left_metric and right_metric implementations
    # note the _format_arg() function though and add appropriate handling there too

class CiftiCreateDenseTimeseriesOutputSpec(TraitedSpec):
    out_file=File(
        exists=True,
        desc="the output cifti file"
    )

class CiftiCreateDenseTimeseries(wb.WBCommand):
    input_spec = CiftiCreateDenseTimeseriesInputSpec
    output_spec = CiftiCreateDenseTimeseriesOutputSpec

    _cmd = 'wb_command -cifti-create-dense-timeseries'


    def _gen_filename(self, name):
        import os

        if name == 'out_file':
            if 'out_file' not in self.inputs.get() or not isdefined(self.inputs.out_file):
                return os.path.join(os.getcwd(), 'dense_cifti.dtseries.nii')
                #self.inputs.out_file = os.path.join(os.getcwd(), 'dense_cifti.dtseries.nii')
            return self.inputs.out_file

    def _list_outputs(self):
        outputs = self.output_spec().get()
        outputs['out_file'] = self._gen_filename('out_file')
        #outputs['out_file'] = self.inputs.out_file

        return outputs


# another quick and dirty implementation
class CiftiMergeInputSpec(CommandLineInputSpec):
    out_file=File(
        argstr='%s',
        position=0,
        genfile=True,
        desc="The output cifti file. Autogenerated if not specified."
    )

    cifti=traits.List(File(exists=True),
        desc='specify an input cifti file list',
        argstr='-cifti %s...',
        mandatory=True,
        position=1)

class CiftiMergeOutputSpec(TraitedSpec):
    out_file=File(
        exists=True,
        desc="the output cifti file"
    )

class CiftiMerge(wb.WBCommand):
    input_spec = CiftiMergeInputSpec
    output_spec = CiftiMergeOutputSpec

    _cmd = 'wb_command -cifti-merge'

    def _gen_filename(self, name):
        import os

        if name == 'out_file':
            if 'out_file' not in self.inputs.get() or not isdefined(self.inputs.out_file):
                return os.path.join(os.getcwd(), 'merged_cifti.dscalar.nii')
            return self.inputs.out_file

    def _list_outputs(self):
        outputs = self.output_spec().get()
        if 'out_file' not in outputs or not isdefined(outputs['out_file']):
            outputs['out_file'] = self._gen_filename('out_file')

        return outputs

# Note: this is another quick and dirty implementation. The dirt comes down to
# specifications of suboptions to -var, which can take -select x y -repeat type
# option. If you want to pass something like that implement a Function interface
# that takes your input file name as input and returns a string that includes
# that filename and the subsequent modifiers.
class CiftiMathInputSpec(CommandLineInputSpec):
    expression=Str(
        argstr='"%s"',
        position=0,
        desc="a mathematical expression to evaluate"
    )
    out_file=File(
        argstr='%s',
        position=1,
        genfile=True,
        desc="the output cifti file. Autogenerated if not specified."
    )
    in_vars=traits.List(traits.Tuple(Str(), traits.Either(File(exists=True), Str())),
        desc='repeatable - a cifti file to use as a variable',
        argstr='-var "%s" %s...',
        mandatory=True,
        position=2
    )

class CiftiMathOutputSpec(TraitedSpec):
    out_file=File(
        exists=True,
        desc="the output cifti file"
    )

class CiftiMath(wb.WBCommand):
    input_spec = CiftiMathInputSpec
    output_spec = CiftiMathOutputSpec

    _cmd = 'wb_command -cifti-math'


    def _gen_filename(self, name):
        import os

        if name == 'out_file':
            if 'out_file' not in self.inputs.get() or not isdefined(self.inputs.out_file):
                return os.path.join(os.getcwd(), 'cifti_math_results.dscalar.nii')
            return self.inputs.out_file

    def _list_outputs(self):
        outputs = self.output_spec().get()
        outputs['out_file'] = self._gen_filename('out_file')

        return outputs


# Note: this is another quick and dirty implementation. It is not as fexible
# as the wb_command CLI. It's specifically designed to work with scenarios
# where an HCP style cifti needs to be merged. If surfaces or volumes differ
# this could break (e.g. if you have cerebellar surfaces) without additional
# mods
class CiftiReduceInputSpec(CommandLineInputSpec):
    in_file=Str(
        argstr='%s',
        position=0,
        desc="the cifti file to reduce"
    )
    operation=traits.Enum('MAX','MIN','INDEXMAX','INDEXMIN','SUM','PRODUCT','MEAN',
        'STDEV','SAMPSTDEV','VARIANCE','TSNR','COV','L2NORM','MEDIAN','MODE','COUNT_NONZERO',
        argstr='%s', 
        position=1,
        mandatory='True',
        desc="the reduction operator to use")
    out_file=File(
        argstr='%s',
        position=2,
        genfile=True,
        desc="the output cifti file. Autogenerated if not specified."
    )

    direction=traits.Enum('COLUMN','ROW', 
        argstr='-direction %s', 
        usedefault=True,
        position=3,
        desc="which direction to separate into components, ROW or COLUMN")

    exclude=traits.List(traits.Tuple(traits.Float(), traits.Float()),
        desc='exclude non-numeric values and outliers by standard deviation. Specify sigma below and sigma above',
        argstr='-exclude-outliers %s %s...',
        mandatory=False,
        position=4)

    numeric=traits.Bool(
        argstr='-only-numeric',
        position=5,
        desc="exclude non-numeric values")

class CiftiReduceOutputSpec(TraitedSpec):
    out_file=File(
        exists=True,
        desc="the output cifti file"
    )

class CiftiReduce(wb.WBCommand):
    input_spec = CiftiReduceInputSpec
    output_spec = CiftiReduceOutputSpec

    _cmd = 'wb_command -cifti-reduce'


    def _gen_filename(self, name):
        import os

        if name == 'out_file':
            if 'out_file' not in self.inputs.get() or not isdefined(self.inputs.out_file):
                return os.path.join(os.getcwd(), 'reduced_cifti.dscalar.nii')
            return self.inputs.out_file

    def _list_outputs(self):
        outputs = self.output_spec().get()
        outputs['out_file'] = self._gen_filename('out_file')

        return outputs


        
        

# a partial implmentation, but should be robust for what it does
class MetricDilateInputSpec(CommandLineInputSpec):
    metric=File(
        argstr='%s',
        position=0,
        exists=True,
        desc="The metric to dilate"
    )
    surface=File(
        argstr='%s',
        position=1,
        exists=True,
        desc="The surface to compute on"
    )
    distance=traits.Float(
        argstr='%s',
        position=2,
        desc="Distance in mm to dilate"
    )
    out_file=File(
        argstr='%s',
        position=4,
        genfile=True,
        desc="The output metric. Autogenerated if not specified."
    )
    nearest=traits.Bool(
        argstr='-nearest',
        position=-1,
        desc="Use the nearest good value instead of a weighted average"
    )

class MetricDilateOutputSpec(TraitedSpec):
    out_file=File(
        exists=True,
        desc="The output metric file"
    )

class MetricDilate(wb.WBCommand):
    input_spec = MetricDilateInputSpec
    output_spec = MetricDilateOutputSpec

    _cmd = 'wb_command -metric-dilate'

    def _gen_filename(self, name):
        import os

        if name == 'out_file':
            if 'out_file' not in self.inputs.get() or not isdefined(self.inputs.out_file):
                return os.path.join(os.getcwd(), 'dilated_metric.func.gii')
            return self.inputs.out_file

    def _list_outputs(self):
        outputs = self.output_spec().get()
        if 'out_file' not in outputs or not isdefined(outputs['out_file']):
            outputs['out_file'] = self._gen_filename('out_file')

        return outputs
