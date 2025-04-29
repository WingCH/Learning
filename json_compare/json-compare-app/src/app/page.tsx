"use client"; // Required for using hooks

import { useState, useEffect } from "react"; // Import useEffect
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Textarea } from "@/components/ui/textarea";
import { Table, TableBody, TableCaption, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { compareJsonStructure, Difference } from "@/lib/compareJsonStructure"; // Import the logic

export default function Home() {
  const [baseJson, setBaseJson] = useState("");
  const [actualJson, setActualJson] = useState("");
  const [results, setResults] = useState<Difference[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  // Load state from localStorage on initial mount
  useEffect(() => {
    const storedBaseJson = localStorage.getItem("baseJson");
    const storedActualJson = localStorage.getItem("actualJson");
    if (storedBaseJson) {
      setBaseJson(storedBaseJson);
    }
    if (storedActualJson) {
      setActualJson(storedActualJson);
    }
  }, []); // Empty dependency array ensures this runs only once on mount

  // Save baseJson to localStorage whenever it changes
  useEffect(() => {
    if (baseJson) { // Avoid saving initial empty string if not intended
      localStorage.setItem("baseJson", baseJson);
    } else {
      localStorage.removeItem("baseJson"); // Clear if empty
    }
  }, [baseJson]);

  // Save actualJson to localStorage whenever it changes
  useEffect(() => {
    if (actualJson) { // Avoid saving initial empty string if not intended
      localStorage.setItem("actualJson", actualJson);
    } else {
      localStorage.removeItem("actualJson"); // Clear if empty
    }
  }, [actualJson]);


  const handleCompare = () => {
    setError(null); // Clear previous errors
    setResults(null); // Clear previous results

    const comparisonResult = compareJsonStructure(baseJson, actualJson);

    if ('error' in comparisonResult) {
      setError(comparisonResult.error);
    } else {
      setResults(comparisonResult);
    }
  };

  return (
    <main className="container mx-auto p-4 md:p-8">
      <h1 className="text-3xl font-bold mb-6 text-center">JSON Structure Comparison Tool</h1>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
        <Card>
          <CardHeader>
            <CardTitle>Base JSON</CardTitle>
            <CardDescription>Paste the expected JSON structure here.</CardDescription>
          </CardHeader>
          <CardContent>
            <Textarea
              placeholder="Paste Base JSON here..."
              rows={15}
              value={baseJson}
              onChange={(e) => setBaseJson(e.target.value)}
              className="font-mono text-sm" // Use monospace font for JSON
            />
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Actual JSON</CardTitle>
            <CardDescription>Paste the actual JSON structure received.</CardDescription>
          </CardHeader>
          <CardContent>
            <Textarea
              placeholder="Paste Actual JSON here..."
              rows={15}
              value={actualJson}
              onChange={(e) => setActualJson(e.target.value)}
              className="font-mono text-sm" // Use monospace font for JSON
            />
          </CardContent>
        </Card>
      </div>

      <div className="text-center mb-6">
        <Button onClick={handleCompare}>Compare Structures</Button>
      </div>

      {/* Display Error Message */}
      {error && (
        <Card className="mb-6 border-destructive bg-destructive/10">
          <CardHeader>
            <CardTitle className="text-destructive">Error</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-destructive">{error}</p>
          </CardContent>
        </Card>
      )}

      {/* Display Results */}
      {results !== null && (
        <Card>
          <CardHeader>
            <CardTitle>Comparison Results</CardTitle>
            <CardDescription>
              {results.length === 0
                ? "No structural differences found."
                : `Found ${results.length} difference(s): `}
              {results.length > 0 && (
                <span className="text-sm">
                  (
                  <span className="text-orange-600">
                    Type Mismatch: {results.filter(d => d.type === 'Type Mismatch').length}
                  </span>
                  ,{' '}
                  <span className="text-red-600">
                    Missing Field: {results.filter(d => d.type === 'Missing Field').length}
                  </span>
                  ,{' '}
                  <span className="text-blue-600">
                    New Field: {results.filter(d => d.type === 'New Field').length}
                  </span>
                  )
                </span>
              )}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Table>
              <TableCaption>A list of structure differences.</TableCaption>
              <TableHeader>
                <TableRow>
                  <TableHead>Change Type</TableHead>
                  <TableHead>Path</TableHead>
                  <TableHead>Expected Type</TableHead>
                  <TableHead>Actual Type</TableHead>
                  <TableHead>Description</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {/* Initial state message - only show if results are null AND no error */}
                {results === null && !error && (
                  <TableRow>
                    <TableCell colSpan={5} className="text-center text-muted-foreground">
                      Click &#34;Compare Structures&#34; to see the results.
                    </TableCell>
                  </TableRow>
                )}
                {/* Render differences if results exist */}
                {results?.map((diff, index) => (
                  <TableRow key={index}>
                    <TableCell className={`font-medium ${diff.type === 'Missing Field' ? 'text-red-600' :
                        diff.type === 'New Field' ? 'text-blue-600' :
                          diff.type === 'Type Mismatch' ? 'text-orange-600' : ''
                      }`}>{diff.type}</TableCell>
                    <TableCell className="font-mono text-sm">{diff.path}</TableCell>
                    <TableCell className="font-mono text-xs">{diff.expectedType ?? '(none)'}</TableCell>
                    <TableCell className="font-mono text-xs">{diff.actualType ?? '(none)'}</TableCell>
                    <TableCell>{diff.description}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      )}
      {/* Only show initial prompt if results are null and no error */}
      {results === null && !error && (
        <div className="text-center text-muted-foreground mt-6">
          {/* This space intentionally left blank if results card isn't shown initially,
                  or add a placeholder card if preferred */}
        </div>
      )}
    </main>
  );
}
