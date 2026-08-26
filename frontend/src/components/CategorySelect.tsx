/**
 * Category select dropdown that fetches options from the API
 */

import { useState, useEffect } from "react";
import { SelectBox } from "../vibes";
import { fetchCategories } from "../services/api";
import { Category } from "../types";

interface CategorySelectProps {
  value: string;
  onChange: (name: string) => void;
  error?: string;
  required?: boolean;
}

export function CategorySelect({
  value,
  onChange,
  error,
  required,
}: CategorySelectProps) {
  const [categories, setCategories] = useState<Category[]>([]);

  useEffect(() => {
    loadCategories();
  }, []);

  const loadCategories = async () => {
    try {
      const data = await fetchCategories();
      setCategories(data);
    } catch (err) {
      console.error("Error loading categories:", err);
    }
  };

  const options = categories.map((c) => ({ value: c.name, label: c.name }));

  return (
    <SelectBox
      label="Category"
      options={options}
      value={value}
      onChange={(e) => onChange(e.target.value)}
      error={error}
      fullWidth
      required={required}
    />
  );
}
