class LicenseModelsController < InheritedResources::Base

  belongs_to :ontology

  def index
    @ontology = Ontology.find(params[:ontology_id])
    @license_models = @ontology.license_models
    @repo = Repository.find_by_path(params[:repository_id])
    
  end
  
  def new
    @license = LicenseModel.new
    @ontology = Ontology.find(params[:ontology_id])
    respond_to do |format|
      format.html 
      format.json { render json: @license }
    end
  end

  def edit
    @ontology = Ontology.find(params[:ontology_id])
    @license = LicenseModel.find(params[:id])
  end

  def create
    @ontology = Ontology.find(params[:ontology_id])
    @license = LicenseModel.new(params[:license_model])
    @repo = Repository.find_by_path(params[:repository_id])

    respond_to do |format|
      if @license.save
        format.html { redirect_to repository_ontology_license_models_path, notice: 'LicenseModel was successfully created.' }
        format.json { render json: @license, status: :created, location: @license }
      else
        format.html { render action: "new" }
        format.json { render json: @license.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @license = LicenseModel.find(params[:id])

    respond_to do |format|
      if @license.update_attributes(params[:license])
        format.html { redirect_to @license, notice: 'LicenseModel was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @license.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @license = LicenseModel.find(params[:id])
    @license.destroy

    respond_to do |format|
      format.html { redirect_to licenses_url }
      format.json { head :no_content }
    end
  end
end
