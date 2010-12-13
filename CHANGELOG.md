Changelog
=========

### 0.6.1
  * (ihoka) Extended #changed? on the ActiveRecord model to indicate the record has been changed if the associated Friendly has changed.

### 0.6.0
  * (ihoka) Added #friendly_details_build_options method to the ActiveRecord model, allowing to specify default attributes when initially building the Friendly model.

### 0.5.0
  
  * (ihoka) Added configurable active_record_key to the FriendlyDetails model. active_record_key affects the name of the generated Friendly index table and the attribute in which the ActiveRecord model ID is stored. It defaults to :active_record_id.

### 0.4.0
  
  * (ihoka) Added #attributes method to FriendlyAttributes::Details base class.

### 0.3.2
  
  * (ihoka) Added description to spec matcher.

### 0.3.1
  
  * (ihoka) added spec matchers

### 0.3.0

  * (ihoka) Extended the DSL to allow passing a hash of options when defining friendly_attributes.
