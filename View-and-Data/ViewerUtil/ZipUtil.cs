using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ICSharpCode.SharpZipLib.Core;
using ICSharpCode.SharpZipLib.Zip;
using System.IO;

namespace ViewerUtil
{
    public class ZipUtil
    {
        public static void ExtractZipFile(string archiveFilenameIn, string password, string outFolder)
        {
            ZipFile zf = null;
            try
            {
                FileStream fs = File.OpenRead(archiveFilenameIn);
                zf = new ZipFile(fs);
                if (!String.IsNullOrEmpty(password))
                {
                    zf.Password = password;     // AES encrypted entries are handled automatically
                }
                foreach (ZipEntry zipEntry in zf)
                {
                    if (!zipEntry.IsFile)
                    {
                        continue;           // Ignore directories
                    }
                    String entryFileName = zipEntry.Name;
                    // to remove the folder from the entry:- entryFileName = Path.GetFileName(entryFileName);
                    // Optionally match entrynames against a selection list here to skip as desired.
                    // The unpacked length is available in the zipEntry.Size property.

                    byte[] buffer = new byte[4096];     // 4K is optimum
                    Stream zipStream = zf.GetInputStream(zipEntry);

                    // Manipulate the output filename here as desired.
                    String fullZipToPath = Path.Combine(outFolder, entryFileName);
                    string directoryName = Path.GetDirectoryName(fullZipToPath);
                    if (directoryName.Length > 0)
                        Directory.CreateDirectory(directoryName);

                    // Unzip file in buffered chunks. This is just as fast as unpacking to a buffer the full size
                    // of the file, but does not waste memory.
                    // The "using" will close the stream even if an exception occurs.
                    using (FileStream streamWriter = File.Create(fullZipToPath))
                    {
                        StreamUtils.Copy(zipStream, streamWriter, buffer);
                    }
                }
            }
            finally
            {
                if (zf != null)
                {
                    zf.IsStreamOwner = true; // Makes close also shut the underlying stream
                    zf.Close(); // Ensure we release resources
                }
            }
        }

        //        public static void UnzipAndSave(HttpPostedFile postedFile)
        //{
        //    ZipInputStream s = new ZipInputStream(postedFile.InputStream);

        //    ZipEntry theEntry;
        //    string virtualPath = "~/uploads/";
        //    string fileName = string.Empty;
        //    string fileExtension = string.Empty;
        //    string fileSize = string.Empty;

        //    while ((theEntry = s.GetNextEntry()) != null)
        //    {
        //        fileName = Path.GetFileName(theEntry.Name);
        //        fileExtension = Path.GetExtension(fileName);

        //        if (!string.IsNullOrEmpty(fileName))
        //        {
        //            try
        //            {
        //                FileStream streamWriter = File.Create(Server.MapPath(virtualPath + fileName));
        //                int size = 2048;
        //                byte[] data = new byte[2048];

        //                do
        //                {
        //                    size = s.Read(data, 0, data.Length);
        //                    streamWriter.Write(data, 0, size);
        //                } while (size > 0);

        //                fileSize = Convert.ToDecimal(streamWriter.Length / 1024).ToString() + ” KB”;

        //                streamWriter.Close();

        //                //Add custom code here to add each file to the DB, etc.
        //            }
        //            catch (Exception ex)
        //            {
        //                Response.Write(ex.ToString());
        //            }
        //        }
        //    }

        //    s.Close();
        //}

        private string GetCurrentPath()
        {
            string assemblyFile = (
                new System.Uri(System.Reflection.Assembly.GetExecutingAssembly().CodeBase)
            ).LocalPath;

            return assemblyFile;
        }

        private string GetTempUnzipFolderPath()
        {
            string path = GetCurrentPath() + "\\unzipped";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
           
            //clear the temp folder
            foreach (var file in Directory.GetFiles(path))
            {
                File.Delete(file);
            }
           

            return path;
        }

    }
}