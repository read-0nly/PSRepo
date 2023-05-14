# This uses 4 data streams to manage
# $DATA, which is simply the main data stream of the file (what you get when you open the file), created as part of standard file structure
# DATABackup, which is the second copy of the data, created by the script
# FileHash, the MD5 hash of the file, created by the script
# FLAG, which has the error state of scanning, if any, for user intervention on validation runs.

# This also lays the groundwork for identifying duplicates across the drive through comparision of these precalc'd hashes tied to the file as well
# ADS has some strange limitations - for one, it doesn't show as using any disk, even though it very much does. 
# I am not sure what happens when this starts to overflow the drive

# It should also provide a local layer of ransomware protection, to some extentr. ADS is part of NTFS, after an attack you should be able to 
# use the second data stream to overwrite the main data stream and recover the original file. This should not be your only layer of protection.

# Scan Mode
	# Gather files
	# For each file
		# If the file has no hash stream
			# Clone file to secondary stream
			# Hash file and set hash stream
		# Else
			# if second stream doesn't exist
				# if main stream hash matches hash
					# copy main stream to second and continue
				#else
					# flag [NoSecond] and continue
			# Calculate hash of both streams
			# if main stream doesn't match hash or second doesn't match hash
				# if main stream doesn't match hash and second doesn't match hash
					# flag [NoMatch] and continue
				# else if main stream doesn't match hash
					# flag [MainChanged] and continue
				# else if second stream doesn't match hash
					# copy main to second

# Validate Mode
	# Gather files
	# For each file
		# If the file has no hash stream
			# Clone file to secondary stream
			# Hash file and set hash stream
		# Else
			#switch flag
				# [NoSecond]
					#if user wants to open file
						#open file
					#if user wants to accept new file
						#copy main to second
						#calc hash from main
						#remove flag
				# [NoMatch]
					#if user wants to open file
						#open file
					#if user wants to accept new file
						#copy main to second
						#calc hash from main
						#remove flag
				# [MainChanged]
					#if user wants to open file
						#open file
					#if user wants to accept new file
						#copy main to second
						#calc hash from main
						#remove flag
