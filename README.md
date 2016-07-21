JUValidate is a library to easily write object graph validations, usually to verify object graphs returned by some third party API contains correctly formatted data. Here is an example for how you might usually write validations in Objective-C (or, because it's tedious, you might just skip out on it completely):

	- (void)myFunction:(NSDictionary *)input
	{
		id name = [input objectForKey:@"name"];
		if(![name isKindOfClass:[NSString class]])
			return; // Probably indicate some error here...

		id value = [input objectForKey:@"value"];
		if(![value isKindOfClass:[NSNumber class]])
			return; // Also error indication here...

		NSInteger number = [value integerValue];
		if(number < 5 || number > 60)
			return; // Aaaaand guess what?

		// Do something with 2 sanitized values
	}

With JUValidate on the other hand, it becomes as simple as this:

	- (void)myFunction:(NSDictionary *)input
	{
			JUValidator *validator = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) {

				validator.valueForKey(@"name").isClass([NSString class]);
				validator.valueForKey(@"value").number.isInRange(@(5), @(60));

			}];
	
			NSError *error;
			BOOL result = [validator validateObject:input error:&error];
	
			if(!result)
				return; // Hey, there already IS an error!
	}
	