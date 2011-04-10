Changelog
=========

### 0.7.1
  * (ihoka) updated dependency for Friendly to ihoka-friendly

### 0.7.0
  * (ihoka,cristi) Support for associating multiple FriendlyAttributes models with a single ActiveRecord model
  * (ihoka,cristi) FriendlyAttributes::Details renamed to FriendlyAttributes::Base
  * (ihoka,cristi) Documentation

### 0.6.1
  * (ihoka,cristi) Extended #changed? on the ActiveRecord model to indicate the record has been changed if the associated Friendly has changed.

### 0.6.0
  * (ihoka,cristi) Added #friendly_details_build_options method to the ActiveRecord model, allowing to specify default attributes when initially building the Friendly model.

### 0.5.0
  
  * (ihoka,cristi) Added configurable active_record_key to the FriendlyDetails model. active_record_key affects the name of the generated Friendly index table and the attribute in which the ActiveRecord model ID is stored. It defaults to :active_record_id.

### 0.4.0
  
  * (ihoka,cristi) Added #attributes method to FriendlyAttributes::Details base class.

### 0.3.2
  
  * (ihoka,cristi) Added description to spec matcher.

### 0.3.1
  
  * (ihoka,cristi) added spec matchers

### 0.3.0

  * (ihoka,cristi) Extended the DSL to allow passing a hash of options when defining friendly_attributes.
