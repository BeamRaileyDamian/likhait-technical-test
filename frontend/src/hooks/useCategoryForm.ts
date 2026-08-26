/**
 * Custom hook for managing category form state and validation
 */

import { useState } from "react";

interface UseCategoryFormProps {
  onSubmit: (name: string) => Promise<void>;
}

export function useCategoryForm({ onSubmit }: UseCategoryFormProps) {
  const [name, setName] = useState("");
  const [error, setError] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleChange = (value: string) => {
    setName(value);
    if (error) setError("");
  };

  const validateForm = (): boolean => {
    if (!name.trim()) {
      setError("Category name is required");
      return false;
    }
    return true;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    setIsSubmitting(true);
    try {
      await onSubmit(name.trim());
      setName("");
      setError("");
    } catch (err: any) {
      setError(err.message || "Failed to create category");
    } finally {
      setIsSubmitting(false);
    }
  };

  return {
    name,
    error,
    isSubmitting,
    handleChange,
    handleSubmit,
  };
}
