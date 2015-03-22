using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

public class OdenImporter : AssetPostprocessor
{
	void OnPreprocessTexture()
	{
		var importer = assetImporter as TextureImporter;
		if(assetImporter == null) return;

		string infoPath = Path.ChangeExtension(assetPath, ".oden");
		if(!File.Exists(infoPath)) return;

		string borderInfo = File.ReadAllText(infoPath);
		var borders = borderInfo.Split(',').Select(s => int.Parse(s.Replace(" px", ""))).ToList();
		// 0L, 1R, 2T, 3B
		Vector4 border = new Vector4 (borders[0], borders[3], borders[1], borders[2]);
		SetBorder(importer, border);
	}

	void SetBorder(TextureImporter importer, Vector4 border)
	{
		importer.textureType = TextureImporterType.Sprite;
		importer.spriteBorder = border;
	}
}
