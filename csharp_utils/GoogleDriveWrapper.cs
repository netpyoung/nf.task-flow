using Google.Apis.Auth.OAuth2;
using Google.Apis.Drive.v3;
using System;
using System.IO;

// ref: https://console.developers.google.com
// ref: https://developers.google.com/drive/


namespace NF.Extra.Utils.Dev
{
	public sealed class GoogleDriveWrapper
	{
		public enum E_SECRET_TYPE
		{
			CLIENT_JSON,
			PROJECT_JSON
		}

		readonly DriveService _service;

		public GoogleDriveWrapper(E_SECRET_TYPE secret_type, string json_fpath)
		{
			this._service = new DriveService(new Google.Apis.Services.BaseClientService.Initializer() {
				HttpClientInitializer = GetCredential(secret_type, json_fpath)
			});
		}

		public string DownloadExcel(string sheet_id, string output_fpath)
		{
			const string mime_type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
			using(var ssteam = this._service.Files.Export(fileId: sheet_id, mimeType: mime_type).ExecuteAsStream())
			{
				using(var fstream = new FileStream(output_fpath, FileMode.Create, FileAccess.Write))
				{
					ssteam.CopyTo(fstream);
					fstream.Flush();
					return output_fpath;
				}
			}
		}

		ICredential GetCredential(E_SECRET_TYPE secret_type, string json_fpath)
		{
			switch(secret_type)
			{
				case E_SECRET_TYPE.CLIENT_JSON:
					return GetClientCredential(json_fpath);

				case E_SECRET_TYPE.PROJECT_JSON:
					return GetProjectCredential(json_fpath);

				default:
					return null;
			}
		}

		GoogleCredential GetProjectCredential(string json_fpath)
		{
			using(var stream = new FileStream(json_fpath, FileMode.Open, FileAccess.Read))
			{
				var scopes = new string[] { DriveService.Scope.Drive };
				var credential = GoogleCredential.FromStream(stream);
				return credential.CreateScoped(scopes);
			}
		}

		UserCredential GetClientCredential(string json_fpath)
		{
			using(var stream = new FileStream(json_fpath, FileMode.Open, FileAccess.Read))
			{
				string path = System.Environment.GetFolderPath(System.Environment.SpecialFolder.Personal);
				path = Path.Combine(path, ".credentials/drive-dotnet-quickstart.json");
				Console.WriteLine(path);
				var dir = Path.GetDirectoryName(path);
				if(!System.IO.Directory.Exists(dir))
					System.IO.Directory.CreateDirectory(dir);

				var scopes = new string[] { DriveService.Scope.Drive };
				var credential = GoogleWebAuthorizationBroker.AuthorizeAsync(
					GoogleClientSecrets.Load(stream).Secrets,
					scopes,
					"user",
					System.Threading.CancellationToken.None,
					new Google.Apis.Util.Store.FileDataStore(path, true)).Result;
				Console.WriteLine("Credential file saved to: " + path);
				return credential;
			}
		}
	}
}
