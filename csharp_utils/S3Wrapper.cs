using Amazon.S3;
using Amazon.S3.Model;
using Amazon.S3.Transfer;
using IniParser;
using IniParser.Model;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;

// NOTE(pyoung):
// Install-Package AWSSDK.S3
// Install-Package ini-parser

namespace NF.Extra.Utils.Dev
{
	public sealed class S3Wrapper
	{
		readonly TransferUtility _transfer_utility;

		public S3Wrapper(string credential_fpath)
		{
			var parser = new FileIniDataParser();
			IniData data = parser.ReadFile(credential_fpath);
			string aws_access_key_id = data["default"]["aws_access_key_id"];
			string aws_secret_access_key = data["default"]["aws_secret_access_key"];

			AmazonS3Client amazon_client = new AmazonS3Client(aws_access_key_id, aws_secret_access_key, Amazon.RegionEndpoint.APNortheast1);
			this._transfer_utility = new TransferUtility(amazon_client);
		}

		public List<string> GetFileList(string bucket_name, string prefix)
		{
			ListObjectsResponse response = this._transfer_utility.S3Client.ListObjects(bucketName: bucket_name, prefix: prefix);
			return response.S3Objects.FindAll(x => x.Size > 0).Select(x => x.Key).ToList();
		}

		public void UploadDirectory(string bucket, string prefix, DirectoryInfo di)
		{
			var request = new TransferUtilityUploadDirectoryRequest {
				BucketName = bucket,
				KeyPrefix = prefix,
				Directory = di.FullName,
				UploadFilesConcurrently = true,
				CannedACL = S3CannedACL.PublicRead,
				SearchOption = SearchOption.AllDirectories,
			};
			request.UploadDirectoryFileRequestEvent += Request_UploadDirectoryFileRequestEvent;
			this._transfer_utility.UploadDirectory(request);
		}

		private void Request_UploadDirectoryFileRequestEvent(object sender, UploadDirectoryFileRequestArgs e)
		{
			e.UploadRequest.Headers.ContentMD5 = GetMD5(e.UploadRequest.FilePath);
			Console.WriteLine(string.Format("{0} => {1}", e.UploadRequest.FilePath, e.UploadRequest.Key));
		}

		string GetMD5(string fpath)
		{
			using(var stream = new FileStream(fpath, FileMode.Open, FileAccess.Read))
			{
				using(var md5 = MD5.Create())
				{
					var md5bytes = md5.ComputeHash(stream);
					return Convert.ToBase64String(md5bytes);
				}
			}
		}

		public void Upload(string bucket, string prefix, params string[] fpaths)
		{
			if(fpaths.Length == 0)
			{
         return;
			}

			foreach(var fpath in fpaths)
			{
				string filename = System.IO.Path.GetFileName(fpath);
				string key = System.IO.Path.Combine(prefix, filename).Replace("\\", "/");
				var request = new TransferUtilityUploadRequest() {
					FilePath = fpath,
					BucketName = bucket,
					Key = key,
					CannedACL = S3CannedACL.PublicRead
				};
				this._transfer_utility.Upload(request);
				Console.WriteLine(string.Format("{0} => {1}", fpath, key));
			}
		}

		public void DownloadDirectory(string bucket, string s3_dir, string local_dir)
		{
			this._transfer_utility.DownloadDirectory(bucket, s3_dir, local_dir);
		}
	}
}
