from nipype.interfaces.base import BaseInterface, BaseInterfaceInputSpec, traits, File, TraitedSpec
from traits.api import List

# this VIF interface code was developed based on a draft from ChatGPT
class VIFCalculationInputSpec(BaseInterfaceInputSpec):
    design_matrix = File(exists=True, desc='Path to design matrix file', mandatory=True)
    contrast_names = List(minlen=1, desc='row names of VIFs (e.g. contrast names)', mandatory=True)

class VIFCalculationOutputSpec(TraitedSpec):
    vif_file = File(exists=True, desc='Output file with VIF calculations')

class VIFCalculation(BaseInterface):
    input_spec = VIFCalculationInputSpec
    output_spec = VIFCalculationOutputSpec

    def _run_interface(self, runtime):
        import os

        vif_results = self.calculate_vif(self.inputs.design_matrix)
        self.vif_file_path = os.path.abspath('vifs.csv')
        with open(self.vif_file_path, 'w') as file:
            for name,vif in zip(self.inputs.contrast_names, vif_results):
                file.write(f"{name},{vif}\n")
        return runtime

    def calculate_vif(self, design_matrix_path):
        import io
        import pandas as pd
        from statsmodels.stats.outliers_influence import variance_inflation_factor as get_vif

        with open(design_matrix_path, 'r') as file:
            lines = file.readlines()[5:]

        # Load the remaining lines as a pandas DataFrame
        design_matrix = pd.read_csv(io.StringIO(''.join(lines)), sep='\s+', header=None)

        # Convert the DataFrame to a numpy array for plotting
        vifs = [get_vif(design_matrix,i) for i in range(0,design_matrix.shape[1])]

        return vifs



    def _list_outputs(self):
        outputs = self.output_spec().get()
        outputs['vif_file'] = self.vif_file_path
        return outputs

